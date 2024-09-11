import 'dart:io';

import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/filesystem.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/views/open_wallet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:monero/monero.dart' as monero;
import 'package:path/path.dart' as p;

class Monero implements Coin {
  @override
  bool get isEnabled {
    try {
      monero.isLibOk();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("monero.dart: isLibOk failed: $e");
        return false;
      }
    }
    return false;
  }

  @override
  CoinStrings get strings => MoneroStrings();

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    final baseDir = Directory(p.join(baseStoragePath, strings.symbolLowercase));
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final wallets =
        monero.WalletManager_findWallets(wmPtr, path: baseDir.path).split(";");
    return Future.value(wallets.map((e) => MoneroWalletInfo(e)).toList());
  }

  @override
  Future<void> createNewWallet(
    String walletName,
    String walletPassword, {
    ProgressCallback? progressCallback,
  }) async {
    progressCallback?.call(
        title: "Creating new wallet", description: "Initializing...");
    final baseDir = Directory(p.join(baseStoragePath, strings.symbolLowercase));
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final String walletPath = p.join(baseDir.path, walletName);
    progressCallback?.call(description: "Generating polyseed");
    final newSeed = monero.Wallet_createPolyseed();
    progressCallback?.call(description: "Creating wallet");
    final newWptr = monero.WalletManager_createWalletFromPolyseed(
      wmPtr,
      path: walletPath,
      password: walletPassword,
      mnemonic: newSeed,
      seedOffset: "",
      newWallet: true,
      restoreHeight: 0,
      kdfRounds: 1,
    );
    progressCallback?.call(description: "Checking status");
    final status = monero.Wallet_status(newWptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(newWptr);
      throw CoinException(
        error,
        details: "unable to create wallet, createWalletFromPolyseed failed.",
      );
    }
    progressCallback?.call(description: "Wallet created");
  }

  @override
  Future<CoinWallet> openWallet(String walletName,
      {required String password}) async {
    final walletExist = monero.WalletManager_walletExists(wmPtr, walletName);
    if (!walletExist) {
      throw Exception("Given wallet doesn't exist");
    }
    final wptr = monero.WalletManager_openWallet(wmPtr,
        path: walletName, password: password);
    final status = monero.Wallet_status(wptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(wptr);
      throw Exception(error);
    }
    return MoneroWallet(wptr);
  }

  @override
  Coins get type => Coins.monero;

  // monero.dart stuff
  monero.WalletManager wmPtr = monero.WalletManagerFactory_getWalletManager();

  @override
  // TODO: implement createMethods
  List<CreateMethods> get createMethods => [
    CreateMethods.create,
    CreateMethods.restoreSeedPolyseed,
    CreateMethods.restoreSeedLegacy,
    CreateMethods.restoreKeysDeterministic,
    CreateMethods.restoreKeys,
  ];
}

class MoneroStrings implements CoinStrings {
  @override
  String get nameLowercase => "monero";
  @override
  String get nameCapitalized => "Monero";
  @override
  String get nameUppercase => "MONERO";
  @override
  String get symbolLowercase => "xmr";
  @override
  String get symbolUppercase => "XMR";
  @override
  String get nameFull => "$nameCapitalized ($symbolUppercase)";
}

class MoneroWalletInfo implements CoinWalletInfo {
  MoneroWalletInfo(this._walletName);

  @override
  Coin get coin => Monero();

  @override
  String get walletName => _walletName;
  final String _walletName;

  @override
  Coins get type => coin.type;

  @override
  void openUI(BuildContext context) {
    OpenWallet.pushStatic(context, this);
  }

  @override
  Future<CoinWallet> openWallet(BuildContext context,
      {required String password}) async {
    return await coin.openWallet(
      _walletName,
      password: password,
    );
  }
}

class MoneroWallet implements CoinWallet {
  MoneroWallet(this.wptr);
  monero.wallet wptr;

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
  String getBalanceString() => (getBalance() / 1e12).toStringAsFixed(8);
}
