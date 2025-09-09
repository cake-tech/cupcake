import 'dart:developer';

import 'package:bitcoin_base/bitcoin_base.dart' hide LitecoinAddress;
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

class LitecoinWallet implements CoinWallet {
  LitecoinWallet({
    required this.seed,
    required final String walletName,
  }) : _walletName = walletName {
    final seed = bip39.mnemonicToSeed(this.seed);
  }

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
  String get getCurrentAddress => wallet.currentAddress;

  @override
  Future<void> handleUR(final BuildContext context, final URQRData ur) async {
    switch (ur.tag) {
      case 'psbt' || '':
        final psbt = Psbt.fromBase64(ur.base64);
        print(psbt.toJson());

        final resp = await CwMweb.psbtGetRecipients(PsbtGetRecipientsRequest(psbtB64: ur.base64));

        final Map<LitecoinAddress, LitecoinAmount> destMap = {};
        for (final recipient in resp.recipient) {
          destMap[LitecoinAddress(recipient.address)] = LitecoinAmount(recipient.value.toInt());
        }
        if (!context.mounted) return;

        await UnconfirmedTransactionView(
          wallet: this,
          destMap: destMap,
          fee: LitecoinAmount(psbt.feeAmount()?.toInt() ?? -1),
          confirmCallback: (final BuildContext context) async {
            final status = await wallet.sign(psbt: psbt);
            if (!status) throw Exception("Failed to sign");
            final sourceBytes = psbt.serialize();
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
          cancelCallback: () => Navigator.of(context).pop(),
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
  String get primaryAddress => wallet.currentAddress;

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
        value: wallet.xpub,
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.qr,
        name: "Pair Cake Wallet",
        value: publicUri.toString(),
      ),
    ];
  }

  Uri get publicUri => Uri(
        scheme: "litecoin",
        queryParameters: {
          "xpub": wallet.xpub,
          // "path": wallet.derivationPath,
          "label": p.basename(walletName),
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
