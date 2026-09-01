import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:bitcoin_base/bitcoin_base.dart' show BtcTransaction, LitecoinAddress;
import 'package:blockchain_utils/blockchain_utils.dart' show BytesUtils;
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/bitcoin/coin.dart';
import 'package:cupcake/coins/bitcoin/creation/common.dart';
import 'package:cupcake/coins/bitcoin/wallet.dart';
import 'package:cupcake/coins/debug/coin_test.dart';
import 'package:cupcake/coins/debug/fixtures.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/coins/litecoin/creation/common.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/creation/common.dart';
import 'package:cupcake/coins/monero/wallet.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/psbt.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cw_mweb/cw_mweb.dart';
import 'package:cw_mweb/mwebd.pbgrpc.dart';
import 'package:ur/cbor_lite.dart';
import 'package:ur/ur.dart';
import 'package:ur/ur_encoder.dart';

/// Wallets the suite creates for itself. They are wiped before and after use,
/// so a leftover here means a run was interrupted.
const _walletPrefix = "cupcake-test-";
const _walletPassword = "cupcake-test";

List<CoinTestCase> coinTestCases(final Coin coin) => switch (coin.type) {
      Coins.monero => _moneroCases(),
      Coins.bitcoin => _bitcoinCases(),
      Coins.litecoin => _litecoinCases(),
      Coins.unknown => [],
    };

class _Holder {
  CoinWallet? wallet;

  T require<T extends CoinWallet>() {
    final wallet = this.wallet;
    if (wallet is! T) throw TestSkipped("the wallet could not be restored");
    return wallet;
  }
}

void _wipeWalletFiles(final String path) {
  for (final file in [File(path), File("$path.keys"), File("$path.address.txt")]) {
    if (file.existsSync()) file.deleteSync();
  }
}

String _hex(final List<int> bytes) =>
    bytes.map((final b) => b.toRadixString(16).padLeft(2, "0")).join();

/// Rebuilds the QR payload an online wallet would have shown, so that the
/// fixtures can be stored as the raw monero blobs they came from.
String _encodeUR(final String tag, final Uint8List payload) {
  final cbor = CBOREncoder();
  cbor.encodeBytes(payload);
  final encoder = UREncoder(UR(tag, cbor.getBytes()), 1000);
  final parts = <String>[];
  while (!encoder.isComplete) {
    parts.add(encoder.nextPart());
  }
  return parts.join("\n");
}

List<CoinTestCase> _bitcoinCases() {
  const name = "${_walletPrefix}btc";
  final holder = _Holder();
  return [
    CoinTestCase("restore from seed", (final log) async {
      final coin = Bitcoin();
      _wipeWalletFiles(coin.getPathForWallet(name));
      final creation = BitcoinWalletCreation(Coin.L);
      await creation.wipe();
      creation.seed.ctrl.text = bip39TestSeed;
      final outcome = await creation.create(CreateMethod.restore, name, _walletPassword);
      expectTrue(outcome?.success ?? false, "restore failed: ${outcome?.message}");
      final wallet = outcome!.wallet! as BitcoinWallet;
      holder.wallet = wallet;
      log("  ${wallet.address.first.address}");
      expectEquals(wallet.address.first.address, bitcoinAddress, "bip84 address");
      expectEquals(wallet.wallet.xpub, bitcoinXpub, "account xpub");
    }),
    CoinTestCase("sign prepared transaction", (final log) async {
      final wallet = holder.require<BitcoinWallet>();
      final psbt = await bdk.PartiallySignedTransaction.fromString(bitcoinUnsignedPsbt);
      expectEquals(psbt.txid(), bitcoinExpectedTxid, "unsigned txid");

      expectTrue(await wallet.wallet.sign(psbt: psbt), "bdk did not sign the transaction");

      final tx = psbt.extractTx();
      expectEquals(tx.txid(), bitcoinExpectedTxid, "signing changed the payment");
      final witness = tx.input().first.witness;
      expectEquals(witness.length, 2, "expected a signature and a pubkey in the witness");
      expectEquals(_hex(witness[1]), bitcoinInputPubkey, "witness pubkey");
      expectEquals(witness[0].last, 0x01, "expected SIGHASH_ALL in signature");
      log("  signature: ${_hex(witness[0])}");
    }),
    CoinTestCase("psbt confirmation warnings", (final log) async {
      // Normal Cake -> Cupcake Bitcoin send: quiet.
      expectEquals(
        psbtConfirmationWarnings(base64.decode(bitcoinCakeWalletUnsignedPsbt)),
        [],
        "cake bitcoin",
      );

      // Witness-only amounts -> fee warning; no sighash field -> no sighash warning.
      final witnessOnly = psbtConfirmationWarnings(base64.decode(bitcoinUnsignedPsbt));
      expectEquals(witnessOnly.length, 1, "witness-only: fee only");
      expectTrue(witnessOnly.single.contains('independently verified'), "fee text");

      // Explicit SIGHASH_NONE (also witness-only -> fee + sighash).
      final none = psbtConfirmationWarnings(base64.decode(bitcoinSighashNonePsbt));
      expectTrue(none.any((final w) => w.contains('SIGHASH_NONE')), "sighash none");
      expectTrue(none.any((final w) => w.contains('independently verified')), "fee too");

      // v2 multi-input: only input 2 is flagged -> one sighash warning.
      final v2 = psbtConfirmationWarnings(base64.decode(bitcoinV2MultiInputSighashNonePsbt));
      expectTrue(
        v2.any((final w) => w.contains('SIGHASH_NONE') && w.contains('1 input')),
        "input 2 only",
      );

      // Litecoin v2 (mwebd witness-only): fee warn, no sighash.
      final ltc = psbtConfirmationWarnings(base64.decode(litecoinUnsignedPsbt));
      expectEquals(ltc.length, 1, "ltc: fee only");
      expectTrue(ltc.single.contains('independently verified'), "ltc fee text");
      log("  cake=[], witness/ltc=fee, sighash=NONE(+fee), v2=input2");
    }),
    CoinTestCase("cleanup", (final log) async {
      await holder.wallet?.close();
      _wipeWalletFiles(Bitcoin().getPathForWallet(name));
    }),
  ];
}

List<CoinTestCase> _litecoinCases() {
  const name = "${_walletPrefix}ltc";
  final holder = _Holder();
  return [
    CoinTestCase("restore from seed", (final log) async {
      final coin = Litecoin();
      _wipeWalletFiles(coin.getPathForWallet(name));
      final creation = LitecoinWalletCreation(Coin.L);
      await creation.wipe();
      creation.seed.ctrl.text = bip39TestSeed;
      final outcome = await creation.create(CreateMethod.restore, name, _walletPassword);
      expectTrue(outcome?.success ?? false, "restore failed: ${outcome?.message}");
      final wallet = outcome!.wallet! as LitecoinWallet;
      holder.wallet = wallet;
      log("  ${wallet.getSegwitAddress}");
      expectEquals(wallet.getSegwitAddress, litecoinAddress, "bip84 address");
    }),
    CoinTestCase("derive mweb address", (final log) async {
      final wallet = holder.require<LitecoinWallet>();
      final address = wallet.getMwebAddress;
      log("  $address");
      expectTrue(address.startsWith("ltcmweb1"), "unexpected mweb address: $address");
    }),
    CoinTestCase("sign prepared transaction", (final log) async {
      final wallet = holder.require<LitecoinWallet>();
      final recipients = await CwMweb.psbtGetRecipients(
        PsbtGetRecipientsRequest(psbtB64: litecoinUnsignedPsbt),
      );
      expectEquals(recipients.recipient.length, 1, "recipient count");
      expectEquals(recipients.recipient.first.address, litecoinDestination, "recipient address");
      expectEquals(
        recipients.recipient.first.value.toInt(),
        litecoinDestinationAmount,
        "recipient amount",
      );
      expectEquals(recipients.fee.toInt(), litecoinFee, "fee");

      final inputProgram =
          LitecoinAddress(recipients.inputAddress.first).baseAddress.addressProgram;
      expectEquals(wallet.pubkeyMap.getExternalIndex(inputProgram), 0, "input address index");

      var signed = await CwMweb.psbtSign(
        PsbtSignRequest(
          psbtB64: litecoinUnsignedPsbt,
          scanSecret: wallet.scanSecret,
          spendSecret: wallet.spendSecret,
        ),
      );
      signed = await CwMweb.psbtSignNonMweb(
        PsbtSignNonMwebRequest(
          psbtB64: signed.psbtB64,
          privKey: wallet.wpkhHd.derivePath("0/0").privateKey.raw,
          index: 0,
        ),
      );
      expectTrue(signed.psbtB64 != litecoinUnsignedPsbt, "the psbt came back unchanged");

      final extracted = await CwMweb.psbtExtract(PsbtExtractRequest(psbtB64: signed.psbtB64));
      final tx = BtcTransaction.fromRaw(BytesUtils.toHexString(extracted.rawTx));
      expectEquals(tx.txId(), litecoinExpectedTxid, "signing changed the payment");
      final witness = tx.witnesses.first.stack;
      expectEquals(witness.length, 2, "expected a signature and a pubkey in the witness");
      expectEquals(witness[1], litecoinInputPubkey, "witness pubkey");
      log("  signature: ${witness[0]}");
    }),
    CoinTestCase("cleanup", (final log) async {
      await holder.wallet?.close();
      _wipeWalletFiles(Litecoin().getPathForWallet(name));
    }),
  ];
}

Future<MoneroWallet> _restoreMonero(final String name, final String seed) async {
  final coin = Monero();
  for (final open in Monero.wPtrList) {
    Monero.wm.closeWallet(open, false);
  }
  Monero.wPtrList.clear();
  _wipeWalletFiles(coin.getPathForWallet(name));
  final creation = MoneroWalletCreation(Coin.L);
  await creation.wipe();
  creation.seed.ctrl.text = seed;
  final outcome = await creation.create(CreateMethod.restore, name, _walletPassword);
  expectTrue(outcome.success, "restore failed: ${outcome.message}");
  return outcome.wallet! as MoneroWallet;
}

List<CoinTestCase> _moneroCases() {
  const legacyName = "${_walletPrefix}xmr-legacy";
  const polyseedName = "${_walletPrefix}xmr";
  final holder = _Holder();
  return [
    CoinTestCase("restore from a 25 word seed", (final log) async {
      final wallet = await _restoreMonero(legacyName, moneroLegacySeed);
      log("  ${wallet.address.first.address}");
      expectEquals(wallet.address.first.address, moneroLegacyAddress, "primary address");
      expectEquals(wallet.legacySeed, moneroLegacySeed, "seed round trip");
      await wallet.close();
    }),
    CoinTestCase("restore from a polyseed", (final log) async {
      final wallet = await _restoreMonero(polyseedName, moneroPolyseed);
      holder.wallet = wallet;
      log("  ${wallet.address.first.address}");
      expectEquals(wallet.address.first.address, moneroPolyseedAddress, "primary address");
      expectEquals(wallet.polyseed, moneroPolyseed, "seed round trip");
    }),
    CoinTestCase("import outputs and sign prepared transaction", (final log) async {
      if (moneroOutputsBase64.isEmpty) {
        throw TestSkipped("no captured transaction, see lib/coins/debug/fixtures.dart");
      }
      final wallet = holder.require<MoneroWallet>().wallet;

      wallet.importOutputsUR(_encodeUR("xmr-output", base64Decode(moneroOutputsBase64)));
      expectEquals(wallet.status(), 0, "importOutputsUR: ${wallet.errorString()}");

      final tx = wallet.loadUnsignedTxUR(
        input: _encodeUR("xmr-txunsigned", base64Decode(moneroUnsignedTxBase64)),
      );
      expectEquals(wallet.status(), 0, "loadUnsignedTxUR: ${wallet.errorString()}");
      expectEquals(tx.status(), 0, "unsigned transaction: ${tx.errorString()}");
      expectEquals(tx.txCount(), 1, "transaction count");
      expectEquals(tx.recipientAddress(), moneroDestination, "recipient");
      expectEquals(tx.amount(), "$moneroAmount", "amount");
      expectEquals(tx.fee(), "$moneroFee", "fee");

      final signed = tx
          .signUR(CupcakeConfig.instance.maxFragmentLength)
          .split("\n")
          .where((final part) => part.isNotEmpty)
          .toList();
      expectEquals(wallet.status(), 0, "signUR: ${wallet.errorString()}");
      expectEquals(tx.status(), 0, "signed transaction: ${tx.errorString()}");
      expectTrue(signed.isNotEmpty, "signUR returned nothing");
      expectTrue(
        signed.first.startsWith("ur:xmr-txsigned/"),
        "unexpected UR fragment: ${signed.first}",
      );
      log("  ${signed.length} signed UR fragment(s)");
    }),
    CoinTestCase("cleanup", (final log) async {
      await holder.wallet?.close();
      _wipeWalletFiles(Monero().getPathForWallet(legacyName));
      _wipeWalletFiles(Monero().getPathForWallet(polyseedName));
    }),
  ];
}
