import 'dart:convert';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/exception.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/monero/amount.dart';
import 'package:cupcake/coins/monero/cache_keys.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/null_if_empty.dart';
import 'package:cupcake/coins/abstract/address.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/views/animated_qr_page.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:monero/src/wallet2.dart';
import 'package:polyseed/polyseed.dart';

class MoneroWallet implements CoinWallet {
  MoneroWallet(this.wallet);
  Wallet2Wallet wallet;

  void save() {
    wallet.store();
  }

  @override
  Coin coin = Monero();

  @override
  List<String> get connectCakeWalletQRCode => [pairQrString];

  @override
  bool get hasAccountSupport => true;
  @override
  bool get hasAddressesSupport => true;

  int _accountIndex = 0;
  @override
  int getAccountsCount() => wallet.numSubaddressAccounts();
  @override
  void setAccount(final int accountIndex) {
    if (_accountIndex < getAccountsCount()) {
      throw Exception(Coin.L.error_account_index_higher_than_count);
    }
    _accountIndex = accountIndex;
    save();
  }

  @override
  int getAccountId() => _accountIndex;

  @override
  int get addressIndex => wallet.numSubaddresses(accountIndex: getAccountId());

  @override
  String get getAccountLabel =>
      wallet.getSubaddressLabel(accountIndex: _accountIndex, addressIndex: 0);

  @override
  String get getCurrentAddress =>
      wallet.address(accountIndex: getAccountId(), addressIndex: addressIndex);

  @override
  int getBalance() => wallet.balance(accountIndex: getAccountId());

  @override
  String getBalanceString() => (getBalance() / 1e12).toStringAsFixed(12);

  Future<void> exportKeyImagesUR(final BuildContext context) async {
    final allImages = wallet
        .exportKeyImagesUR(
          max_fragment_length: CupcakeConfig.instance.maxFragmentLength,
          all: true,
        )
        .split("\n");
    final someImages = wallet
        .exportKeyImagesUR(
          max_fragment_length: CupcakeConfig.instance.maxFragmentLength,
          all: false,
        )
        .split("\n");
    await AnimatedURPage(
      urqrList: {
        Coin.L.partial_key_images: someImages,
        Coin.L.all_key_images: allImages,
      },
      currentWallet: this,
    ).pushReplacement(context);
  }

  @override
  Future<void> handleUR(final BuildContext context, final URQRData ur) async {
    switch (ur.tag) {
      case "xmr-keyimage" || "xmr-txsigned":
        throw Exception("Unable to handle ${ur.tag}. This is a offline wallet");
      case "xmr-output":
        wallet.importOutputsUR(ur.inputs.join("\n"));
        final status = wallet.status();
        if (status != 0) {
          final error = wallet.errorString();
          throw CoinException(error);
        }
        await exportKeyImagesUR(context);
        save();
      case "xmr-txunsigned":
        final tx = wallet.loadUnsignedTxUR(input: ur.inputs.join("\n"));
        var status = wallet.status();
        if (status != 0) {
          final error = wallet.errorString();
          throw CoinException(error);
        }
        status = tx.status();
        if (status != 0) {
          final error = tx.errorString();
          throw CoinException(error);
        }
        final Map<Address, MoneroAmount> destMap = {};
        final amts = tx.amount().split(";").map((final e) => int.parse(e)).toList();
        final addrs = tx.recipientAddress().split(";");
        if (amts.length != addrs.length) {
          throw CoinException(Coin.L.error_amount_and_address_count_not_equal);
        }
        for (int i = 0; i < amts.length; i++) {
          destMap[Address(addrs[i])] = MoneroAmount(amts[i]);
        }
        final fee = MoneroAmount(int.parse(tx.fee()));
        await UnconfirmedTransactionView(
          wallet: this,
          destMap: destMap,
          fee: fee,
          confirmCallback: (final BuildContext context) async {
            final signedTx = tx.signUR(CupcakeConfig.instance.maxFragmentLength).split("\n");
            var status = wallet.status();
            if (status != 0) {
              final error = wallet.errorString();
              throw CoinException(error);
            }
            status = tx.status();
            if (status != 0) {
              final error = tx.errorString();
              throw CoinException(error);
            }
            await AnimatedURPage(
              urqrList: {"signedTx": signedTx},
              currentWallet: this,
            ).pushReplacement(context);
          },
          cancelCallback: () => Navigator.of(context).pop(),
        ).pushReplacement(context);
        save();
      default:
        throw UnimplementedError(Coin.L.error_ur_tag_unsupported(ur.tag));
    }
  }

  String get seedOffset => wallet.getCacheAttribute(key: MoneroCacheKeys.seedOffsetCacheKey);

  @override
  String get passphrase => seedOffset;

  set seedOffset(final String newSeedOffset) => wallet.setCacheAttribute(
        key: MoneroCacheKeys.seedOffsetCacheKey,
        value: newSeedOffset,
      );

  @override
  String get seed =>
      (polyseed ?? "").nullIfEmpty() ?? (polyseedDart ?? "").nullIfEmpty() ?? legacySeed;

  String? get polyseed => wallet.getPolyseed(passphrase: seedOffset);

  String? get polyseedDart {
    try {
      const coin = PolyseedCoin.POLYSEED_MONERO;
      final lang = PolyseedLang.getByName("English");

      final polyseedString =
          polyseed ?? wallet.getCacheAttribute(key: MoneroCacheKeys.seedCacheKey);

      final seed = Polyseed.decode(polyseedString, lang, coin);
      if (seedOffset.isNotEmpty) {
        seed.crypt(seedOffset);
      }
      return seed.encode(lang, coin);
    } catch (e) {
      print("polyseedDart failed: $e");
      // this is fine, we don't care
      return null;
    }
  }

  String get legacySeed => wallet.seed(seedOffset: seedOffset);

  @override
  String get walletName => p.basename(wallet.path());

  @override
  Future<void> close() {
    Monero.wm.closeWallet(wallet, true);
    Monero.wPtrList.removeWhere(
      (final element) => element.ffiAddress() == wallet.ffiAddress(),
    );
    return Future.value();
  }

  @override
  String get primaryAddress => wallet.address(
        accountIndex: 0,
        addressIndex: 0,
      );

  @override
  Future<List<WalletSeedDetail>> seedDetails() async {
    return [
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.primary_address_label,
        value: primaryAddress,
      ),
      if ((polyseed ?? "").isNotEmpty)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: Coin.L.seed_screen_wallet_seed_polyseed,
          value: polyseed!,
        ),
      if ((polyseedDart ?? "").isNotEmpty && polyseedDart != polyseed)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: Coin.L.seed_screen_wallet_seed_polyseed_encrypted,
          value: polyseedDart!,
        ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.seed_screen_wallet_seed_legacy,
        value: legacySeed,
      ),
      if (seedOffset.isNotEmpty)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: Coin.L.seed_offset,
          value: seedOffset,
        ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.view_key,
        value: wallet.publicViewKey(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.secret_view_key,
        value: wallet.secretViewKey(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.spend_key,
        value: wallet.publicSpendKey(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.secret_spend_key,
        value: wallet.secretSpendKey(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: Coin.L.restore_height,
        value: wallet.getRefreshFromBlockHeight().toString(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.qr,
        name: Coin.L.view_only_restore_qr,
        value: pairQrString,
      ),
    ];
  }

  String get pairQrString => const JsonEncoder.withIndent('   ').convert({
        "version": 0,
        "primaryAddress": primaryAddress,
        "privateViewKey": wallet.secretViewKey(),
        "restoreHeight": wallet.getRefreshFromBlockHeight(),
      });
}
