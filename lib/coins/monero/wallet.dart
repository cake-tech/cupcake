import 'dart:convert';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/coin_exception.dart';
import 'package:cupcake/coins/abstract/coin_wallet.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/coins/types.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/null_if_empty.dart';
import 'package:cupcake/utils/secure_storage.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/unconfirmed_transaction_view_model.dart';
import 'package:cupcake/view_model/urqr_view_model.dart';
import 'package:cupcake/views/unconfirmed_transaction.dart';
import 'package:cupcake/views/urqr.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:monero/monero.dart' as monero;
import 'package:polyseed/polyseed.dart';

const seedOffsetCacheKey = "cakewallet.passphrase";
const seedCacheKey = "cakewallet.seed";

class MoneroWallet implements CoinWallet {
  MoneroWallet(this.wptr);
  monero.wallet wptr;

  void save() {
    monero.Wallet_store(wptr);
  }

  @override
  Coin coin = Monero();

  @override
  bool get hasAccountSupport => true;
  @override
  bool get hasAddressesSupport => true;

  int _accountIndex = 0;
  @override
  int getAccountsCount() => monero.Wallet_numSubaddressAccounts(wptr);
  @override
  void setAccount(int accountIndex) {
    if (_accountIndex < getAccountsCount()) {
      throw Exception("Given index is larger than current account count");
    }
    _accountIndex = accountIndex;
    save();
  }

  @override
  int getAccountId() => _accountIndex;

  @override
  int get addressIndex =>
      monero.Wallet_numSubaddresses(wptr, accountIndex: getAccountId());

  @override
  String get getAccountLabel => monero.Wallet_getSubaddressLabel(wptr,
      accountIndex: _accountIndex, addressIndex: 0);

  @override
  String get getCurrentAddress => monero.Wallet_address(wptr,
      accountIndex: getAccountId(), addressIndex: addressIndex);

  @override
  int getBalance() => monero.Wallet_balance(wptr, accountIndex: getAccountId());

  @override
  String getBalanceString() => (getBalance() / 1e12).toStringAsFixed(12);

  Future<void> exportKeyImagesUR(BuildContext context) async {
    final allImages = monero.Wallet_exportKeyImagesUR(wptr,
            max_fragment_length: config.maxFragmentLength, all: true)
        .split("\n");
    final someImages = monero.Wallet_exportKeyImagesUR(wptr,
            max_fragment_length: config.maxFragmentLength, all: false)
        .split("\n");
    await AnimatedURPage.staticPush(
      context,
      URQRViewModel(
        urqrList: {
          "Partial Key Images": someImages,
          "All Key Images": allImages,
        },
      ),
    );
  }

  @override
  Future<void> handleUR(BuildContext context, URQRData ur) async {
    print("handling: ${ur.tag}.");
    switch (ur.tag) {
      case "xmr-keyimage" || "xmr-txsigned":
        throw Exception("Unable to handle ${ur.tag}. This is a offline wallet");
      case "xmr-output":
        monero.Wallet_importOutputsUR(wptr, ur.inputs.join("\n"));
        var status = monero.Wallet_status(wptr);
        if (status != 0) {
          final error = monero.Wallet_errorString(wptr);
          throw CoinException(error);
        }
        exportKeyImagesUR(context);
        save();
      case "xmr-txunsigned":
        print("handling tx-unsignex");
        final txptr =
            monero.Wallet_loadUnsignedTxUR(wptr, input: ur.inputs.join("\n"));
        var status = monero.Wallet_status(wptr);
        if (status != 0) {
          final error = monero.Wallet_errorString(wptr);
          throw CoinException(error);
        }
        status = monero.UnsignedTransaction_status(txptr);
        if (status != 0) {
          final error = monero.UnsignedTransaction_errorString(txptr);
          throw CoinException(error);
        }
        Map<Address, MoneroAmount> destMap = {};
        final amts = monero.UnsignedTransaction_amount(txptr)
            .split(";")
            .map((e) => int.parse(e))
            .toList();
        final addrs =
            monero.UnsignedTransaction_recipientAddress(txptr).split(";");
        if (amts.length != addrs.length) {
          throw CoinException("Amount and address length is not equal.");
        }
        for (int i = 0; i < amts.length; i++) {
          destMap[Address(addrs[i])] = MoneroAmount(amts[i]);
        }
        final fee =
            MoneroAmount(int.parse(monero.UnsignedTransaction_fee(txptr)));
        await UnconfirmedTransactionView.staticPush(
          context,
          UnconfirmedTransactionViewModel(
            wallet: this,
            destMap: destMap,
            fee: fee,
            confirmCallback: (BuildContext context) async {
              final signedTx = monero.UnsignedTransaction_signUR(
                      txptr, config.maxFragmentLength)
                  .split("\n");
              var status = monero.Wallet_status(wptr);
              if (status != 0) {
                final error = monero.Wallet_errorString(wptr);
                throw CoinException(error);
              }
              status = monero.UnsignedTransaction_status(txptr);
              if (status != 0) {
                final error = monero.UnsignedTransaction_errorString(txptr);
                throw CoinException(error);
              }
              await AnimatedURPage.staticPush(
                  context, URQRViewModel(urqrList: {"signedTx": signedTx}));
            },
            cancelCallback: (BuildContext context) => {},
          ),
        );
        save();
      default:
        throw UnimplementedError("Unable to handle ${ur.tag}.");
    }
  }

  // TODO: make this match the offset used in cake wallet, and define const
  String get seedOffset =>
      monero.Wallet_getCacheAttribute(wptr, key: seedOffsetCacheKey);

  set seedOffset(String newSeedOffset) => monero.Wallet_setCacheAttribute(
        wptr,
        key: seedOffsetCacheKey,
        value: newSeedOffset,
      );

  @override
  String get seed =>
      (polyseed ?? "").nullIfEmpty() ??
      (polyseedDart ?? "").nullIfEmpty() ??
      legacySeed;

  String? get polyseed =>
      monero.Wallet_getPolyseed(wptr, passphrase: seedOffset);

  String? get polyseedDart {
    try {
      const coin = PolyseedCoin.POLYSEED_MONERO;
      var lang = PolyseedLang.getByName("English");

      var polyseedString =
          polyseed ?? monero.Wallet_getCacheAttribute(wptr, key: seedCacheKey);

      var seed = Polyseed.decode(polyseedString, lang, coin);
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

  String get legacySeed => monero.Wallet_seed(wptr, seedOffset: seedOffset);

  @override
  String get walletName => p.basename(monero.Wallet_path(wptr));

  @override
  Future<void> close() {
    monero.WalletManager_closeWallet(Monero.wmPtr, wptr, true);
    wPtrList.removeWhere((element) => element.address == wptr.address);
    return Future.value();
  }

  @override
  String get primaryAddress => monero.Wallet_address(
        wptr,
        accountIndex: 0,
        addressIndex: 0,
      );

  @override
  Future<List<WalletSeedDetail>> seedDetails(AppLocalizations L) async {
    final secrets = await secureStorage.readAll();
    return [
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.primary_address_label,
        value: monero.Wallet_address(wptr, accountIndex: 0, addressIndex: 0),
      ),
      if ((polyseed ?? "").isNotEmpty)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: L.seed_screen_wallet_seed_polyseed,
          value: polyseed!,
        ),
      if ((polyseedDart ?? "").isNotEmpty && polyseedDart != polyseed)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: L.seed_screen_wallet_seed_polyseed_encrypted,
          value: polyseedDart!,
        ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.seed_screen_wallet_seed_legacy,
        value: legacySeed,
      ),
      if (seedOffset.isNotEmpty)
        WalletSeedDetail(
          type: WalletSeedDetailType.text,
          name: L.seed_offset,
          value: seedOffset,
        ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.view_key,
        value: monero.Wallet_publicViewKey(wptr),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.secret_view_key,
        value: monero.Wallet_secretViewKey(wptr),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.spend_key,
        value: monero.Wallet_publicSpendKey(wptr),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.secret_spend_key,
        value: monero.Wallet_secretSpendKey(wptr),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.text,
        name: L.restore_height,
        value: monero.Wallet_getRefreshFromBlockHeight(wptr).toString(),
      ),
      WalletSeedDetail(
        type: WalletSeedDetailType.qr,
        name: L.view_only_restore_qr,
        value: const JsonEncoder.withIndent('   ').convert({
          "version": 0,
          "primaryAddress":
              monero.Wallet_address(wptr, accountIndex: 0, addressIndex: 0),
          "privateViewKey": monero.Wallet_secretViewKey(wptr),
          "restoreHeight": monero.Wallet_getRefreshFromBlockHeight(wptr),
        }),
      ),
      if (config.debug)
        ...List.generate(
          secrets.keys.length,
          (index) {
            final key = secrets.keys.elementAt(index);
            return WalletSeedDetail(
                type: WalletSeedDetailType.text,
                name: key,
                value: secrets[key] ?? "unknown");
          },
        ),
      if (config.debug)
        ...List.generate(
          config.toJson().keys.length,
          (index) {
            final key = config.toJson().keys.elementAt(index);
            return WalletSeedDetail(
                type: WalletSeedDetailType.text,
                name: key,
                value: const JsonEncoder.withIndent('    ')
                    .convert(config.toJson()[key]));
          },
        ),
    ];
  }
}

class MoneroAmount implements Amount {
  MoneroAmount(this.amount);
  @override
  final int amount;

  @override
  String toString() => monero.Wallet_displayAmount(amount);
}
