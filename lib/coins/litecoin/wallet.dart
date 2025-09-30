import 'dart:convert';
import 'dart:typed_data';

import 'package:bitcoin_base/bitcoin_base.dart';
import 'package:blockchain_utils/blockchain_utils.dart';
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/coins/litecoin/address.dart';
import 'package:cupcake/coins/litecoin/amount.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/coins/litecoin/wallet_info.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/views/animated_qr_page.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:cw_mweb/cw_mweb.dart';
import 'package:cw_mweb/mwebd.pbgrpc.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:ur/cbor_lite.dart';
import 'package:ur/ur.dart';
import 'package:ur/ur_encoder.dart';
import 'package:bip39/bip39.dart' as bip39;

class PubkeyIndexMap {
  PubkeyIndexMap(this.root);

  final Bip32Slip10Secp256k1 root;
  final Map<String, int> externalMap = {};
  final Map<String, int> changeMap = {};

  int nextExternalIndex = 0;
  int nextChangeIndex = 0;

  void topupExternal({final int count = 100}) {
    for (int i = nextExternalIndex; i < nextExternalIndex + count; i++) {
      externalMap[ECPublic.fromBip32(root.derivePath("0/$i").publicKey).toHash160Hex()] = i;
    }
    nextExternalIndex += count;
  }

  void topupChange({final int count = 100}) {
    for (int i = nextChangeIndex; i < nextChangeIndex + count; i++) {
      changeMap[ECPublic.fromBip32(root.derivePath("1/$i").publicKey).toHash160Hex()] = i;
    }
    nextChangeIndex += count;
  }

  int? getExternalIndex(final String pubkey) => externalMap[pubkey];
  int? getChangeIndex(final String pubkey) => changeMap[pubkey];
}

class LitecoinWallet implements CoinWallet {
  factory LitecoinWallet({
    required final String seed,
    required final String walletName,
  }) {
    CwMweb.nodeUriOverride = "http://::1:80";

    final wpkhHd = Bip32Slip10Secp256k1.fromSeed(
      bip39.mnemonicToSeed(seed),
      Bip44Conf.litecoinMainNet.altKeyNetVer,
    ).derivePath("m/84'/2'/0'") as Bip32Slip10Secp256k1;
    final mwebHd = Bip32Slip10Secp256k1.fromSeed(bip39.mnemonicToSeed(seed))
        .derivePath("m/1000'/2'/0'") as Bip32Slip10Secp256k1;

    final pubkeyMap = PubkeyIndexMap(wpkhHd);
    pubkeyMap.topupExternal();
    pubkeyMap.topupChange();

    return LitecoinWallet._(
      seed: seed,
      walletName: walletName,
      wpkhHd: wpkhHd,
      mwebHd: mwebHd,
      pubkeyMap: pubkeyMap,
    );
  }

  const LitecoinWallet._({
    required this.seed,
    required final String walletName,
    required this.wpkhHd,
    required this.mwebHd,
    required this.pubkeyMap,
  }) : _walletName = walletName;

  final Bip32Slip10Secp256k1 wpkhHd;
  final Bip32Slip10Secp256k1 mwebHd;

  final PubkeyIndexMap pubkeyMap;

  List<int> get scanSecret => mwebHd.childKey(Bip32KeyIndex(0x80000000)).privateKey.privKey.raw;
  List<int> get spendSecret => mwebHd.childKey(Bip32KeyIndex(0x80000001)).privateKey.privKey.raw;
  List<int> get spendPubkey =>
      mwebHd.childKey(Bip32KeyIndex(0x80000001)).publicKey.pubKey.compressed;

  @override
  List<String> get connectCakeWalletQRCode => [publicUri.toString()];

  @override
  int get addressIndex => 0;

  @override
  Future<void> close() async {} // no need

  @override
  Coin get coin => Litecoin();

  @override
  int getAccountId() {
    return 0;
  }

  @override
  String get getAccountLabel => "Primary Address";

  @override
  int getAccountsCount() => 1;

  @override
  int getBalance() => -1;

  @override
  String getBalanceString() {
    final balance = getBalance();
    return (balance / 1e8).toStringAsFixed(8);
  }

  @override
  String get getCurrentAddress {
    return getCurrentMwebAddress;
    // final hd = wpkhHd.derivePath("0/0");
    // return ECPublic.fromBip32(hd.publicKey).toP2wpkhAddress().toAddress(LitecoinNetwork.mainnet);
  }

  String get getCurrentMwebAddress {
    return CwMweb.address(Uint8List.fromList(scanSecret), Uint8List.fromList(spendPubkey), 1)!;
  }

  @override
  Future<void> handleUR(final BuildContext context, final URQRData ur) async {
    switch (ur.tag) {
      case 'psbt' || '':
        final psbtB64 = ur.base64;
        final resp = await CwMweb.psbtGetRecipients(PsbtGetRecipientsRequest(psbtB64: psbtB64));

        final Map<LitecoinAddress2, LitecoinAmount> destMap = {};
        for (final recipient in resp.recipient) {
          destMap[LitecoinAddress2(recipient.address)] = LitecoinAmount(recipient.value.toInt());
        }
        if (!context.mounted) return;

        await UnconfirmedTransactionView(
          wallet: this,
          destMap: destMap,
          fee: LitecoinAmount(resp.fee.toInt()),
          confirmCallback: (final BuildContext context) async {
            Uint8List sourceBytes;
            try {
              var resp2 = await CwMweb.psbtSign(
                PsbtSignRequest(
                  psbtB64: psbtB64,
                  scanSecret: scanSecret,
                  spendSecret: spendSecret,
                ),
              );
              for (int i = 0; i < resp.inputAddress.length; i++) {
                late LitecoinAddress address;
                try {
                  address = LitecoinAddress(resp.inputAddress[i]);
                } catch (_) {
                  continue;
                }
                final pubkey = address.baseAddress.addressProgram;
                var index = pubkeyMap.getExternalIndex(pubkey);
                if (index == null) {
                  pubkeyMap.topupExternal();
                  index = pubkeyMap.getExternalIndex(pubkey);
                }
                Bip32PrivateKey? key;
                if (index != null) {
                  key = wpkhHd.derivePath("0/$index").privateKey;
                } else {
                  index = pubkeyMap.getChangeIndex(pubkey);
                  if (index == null) {
                    pubkeyMap.topupChange();
                    index = pubkeyMap.getChangeIndex(pubkey);
                  }
                  if (index != null) {
                    key = wpkhHd.derivePath("1/$index").privateKey;
                  }
                }
                if (key != null) {
                  resp2 = await CwMweb.psbtSignNonMweb(
                    PsbtSignNonMwebRequest(psbtB64: resp2.psbtB64, privKey: key.raw, index: i),
                  );
                }
              }
              sourceBytes = base64.decode(resp2.psbtB64);
            } catch (e) {
              throw Exception("Failed to sign");
            }
            final cborEncoder = CBOREncoder();
            cborEncoder.encodeBytes(sourceBytes);
            final ur = UR("psbt", cborEncoder.getBytes());
            // var ur = UR("psbt", Uint8List.fromList(List.generate(64*1024, (int x) => x % 256)));
            final encoded = UREncoder(ur, 120);
            final List<String> values = [];
            while (!encoded.isComplete) {
              values.add(encoded.nextPart());
            }
            if (!context.mounted) return;
            await AnimatedURPage(
              urqrList: {"signedTx": values},
              currentWallet: this,
            ).pushReplacement(context);
          },
          cancelCallback: (final BuildContext context) => Navigator.of(context).pop(),
        ).pushReplacement(context);
        break;
      default:
        throw Exception("Unable to handle '${ur.tag}' UR tag");
    }
  }

  @override
  bool get hasAccountSupport => false;

  @override
  bool get hasAddressesSupport => true;

  @override
  String get passphrase => "";

  @override
  String get primaryAddress => getCurrentAddress;

  @override
  final String seed;

  @override
  Future<List<WalletSeedDetail>> seedDetails() async {
    return [
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: "Seed",
        value: seed,
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: "xPub",
        value: xpub,
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.view_key,
        value: hex.encode(scanSecret),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.spend_key,
        value: hex.encode(spendPubkey),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.qr,
        name: "Pair Cake Wallet",
        value: publicUri.toString(),
      ),
    ];
  }

  String get xpub => wpkhHd.publicKey.toExtended;

  Uri get publicUri => Uri(
        scheme: "litecoin",
        queryParameters: {
          // "path": wallet.derivationPath,
          "label": p.basename(walletName),
          "xpub": xpub,
          "scan_secret": hex.encode(scanSecret),
          "spend_pubkey": hex.encode(spendPubkey),
        },
      );

  @override
  void setAccount(final int newAccountIndex) {}

  @override
  String get walletName => p.basename(_walletName);

  final String _walletName;

  @override
  CoinWalletInfo get walletInfo => LitecoinWalletInfo(walletName);
}
