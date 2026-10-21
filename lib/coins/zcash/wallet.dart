import 'dart:typed_data';

import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/coins/abstract/amount.dart';
import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/coins/zcash/address_type.dart';
import 'package:cupcake/coins/zcash/coin.dart';
import 'package:cupcake/coins/zcash/utils.dart';
import 'package:cupcake/coins/zcash/wallet_info.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/views/animated_qr_page.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:flutter/widgets.dart';
import 'package:ur/ur.dart';
import 'package:ur/ur_decoder.dart';
import 'package:ur/ur_encoder.dart';
import 'package:zkool/src/rust/api/account.dart' as zkool_account;
import 'package:zkool/src/rust/api/coin.dart' as zkool_coin;
import 'package:zkool/src/rust/api/pay.dart' as zkool_pay;
import 'package:zkool/src/zcash_ur.dart';

class ZcashWallet extends CoinWallet {
  ZcashWallet({required this.u});

  zkool_coin.Coin get c => u.c;
  final ZcashUtils u;

  @override
  List<Address> get address =>
      u.cache?.addresses ?? [Address(UnifiedAddressLabel(), "address null")];

  @override
  int get addressIndex => 0;

  @override
  Coin get coin => Zcash();

  @override
  List<String> get connectCakeWalletQRCode => [u.cache?.connectCakeWalletQRCode ?? ''];

  @override
  String get getAccountLabel => "";

  @override
  bool get hasAccountSupport => false;

  @override
  bool get hasAddressesSupport => false;

  @override
  String get passphrase => u.cache!.passphrase;

  @override
  String get seed => u.cache!.seed;

  @override
  late CoinWalletInfo walletInfo = ZcashWalletInfo(walletName);

  @override
  String get walletName => u.walletName;

  @override
  Future<void> close() async {
    // throw UnimplementedError();
  }

  @override
  int getAccountId() {
    return 1;
  }

  @override
  int getAccountsCount() {
    return 1;
  }

  @override
  int getBalance() {
    return 0;
  }

  @override
  String getBalanceString() {
    return (getBalance() / 100000000).toStringAsFixed(8);
  }

  @override
  Future<void> handleUR(final BuildContext context, final URQRData ur) async {
    if (ur.tag != zcashPcztType) {
      throw Exception("Unable to handle '${ur.tag}' UR tag");
    }
    await u.init();
    final package = await zkool_pay.unsignedPcztPackage(bytes: _decodePczt(ur.inputs));
    final plan = zkool_pay.toPlan(package: package, c: c);
    final changeAddresses = (await zkool_account.internalChangeAddresses(c: c)).toSet();
    if (!context.mounted) return;
    await UnconfirmedTransactionView(
      wallet: this,
      destMap: {
        for (final output in plan.outputs)
          // Ironwood pair each spend with a zero-value output to
          // the note's own receiver. That output is padding, not a payment.
          if (output.amount > BigInt.zero && !changeAddresses.contains(output.address))
            Address(UnknownLabel(), output.address): ZcashAmount(output.amount.toInt()),
      },
      fee: ZcashAmount(plan.fee.toInt()),
      confirmCallback: (final BuildContext context) async {
        final signed = await zkool_pay.signTransaction(pczt: package, c: c);
        if (!context.mounted) return;
        await AnimatedURPage(
          urqrList: {'signedTx': _encodePczt(signed.pczt)},
          currentWallet: this,
        ).pushReplacement(context);
      },
      cancelCallback: (final BuildContext context) => Navigator.of(context).pop(),
    ).pushReplacement(context);
  }

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
        name: "View Key",
        value: u.cache?.viewKey ?? "",
      ),
      if (passphrase.isNotEmpty)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: "Passphrase",
          value: passphrase,
        ),
    ];
  }
}

Uint8List _decodePczt(final List<String> parts) {
  final decoder = URDecoder();
  for (final part in parts) {
    decoder.receivePart(part);
  }
  if (!decoder.isSuccess()) {
    throw const FormatException('Incomplete Zcash QR');
  }
  return decodeZcashPczt((decoder.result as UR).cbor);
}

List<String> _encodePczt(final Uint8List pczt) {
  final encoder = UREncoder(
    UR(zcashPcztType, encodeZcashPczt(pczt)),
    CupcakeConfig.instance.maxFragmentLength,
  );
  final parts = <String>[];
  while (!encoder.isComplete) {
    parts.add(encoder.nextPart());
  }
  return parts;
}

class ZcashAmount implements Amount {
  ZcashAmount(this.amount);

  @override
  final int amount;

  @override
  String toString() => (amount / 100000000).toStringAsFixed(8);
}
