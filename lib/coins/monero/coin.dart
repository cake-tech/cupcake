import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/monero/creation/common.dart';
import 'package:cupcake/coins/monero/strings.dart';
import 'package:cupcake/coins/monero/wallet_info.dart';
import 'package:cupcake/coins/monero/wallet.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:monero/monero.dart' as monero;
import 'package:path/path.dart' as p;

class Monero implements Coin {
  static List<monero.wallet> wPtrList = [];

  @override
  bool get isEnabled {
    try {
      monero.isLibOk();
      return true;
    } catch (e) {
      if (CupcakeConfig.instance.debug) {
        print("monero.dart: isLibOk failed: $e");
        return false;
      }
    }
    return false;
  }

  @override
  CoinStrings get strings => MoneroStrings();

  static final baseDir = Directory(p.join(baseStoragePath, MoneroStrings().symbolLowercase));

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    // NOTE: We cannot use findWallets on iOS because for some reason it crashes
    // It works on other operating systems somewhat good. I'm not debugging that
    // right now.
    // final wallets = monero.WalletManager_findWallets(wmPtr, path: baseDir.path);
    // final status = monero.WalletManager_errorString(wmPtr);
    // if (status != "") {
    //   throw Exception(status);
    // }
    // final retWallets = wallets.map((e) => MoneroWalletInfo(e)).toList();
    // retWallets.removeWhere((element) => element.walletName.trim().isEmpty);
    final List<CoinWalletInfo> retWallets = [];
    final list = baseDir.listSync(recursive: true, followLinks: true);
    for (final element in list) {
      if (element.absolute.path.endsWith(".keys")) continue;
      if (!monero.WalletManager_walletExists(wmPtr, element.absolute.path)) {
        continue;
      }
      retWallets.add(MoneroWalletInfo(element.absolute.path));
    }
    return Future.value(retWallets);
  }

  @override
  String getPathForWallet(final String walletName) {
    final baseDir = Directory(p.join(baseStoragePath, strings.symbolLowercase));
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    // Prevent user from slipping outside allowed directory
    final String walletPath = p.join(baseDir.path, walletName);
    if (!walletPath.startsWith(baseDir.path)) {
      throw Exception("Illegal wallet name: $walletName");
    }
    return walletPath;
  }

  @override
  Future<CoinWallet> openWallet(final CoinWalletInfo walletInfo,
      {required final String password}) async {
    for (final wptr in wPtrList) {
      monero.WalletManager_closeWallet(wmPtr, wptr, true);
    }
    wPtrList.clear();
    final walletExist = monero.WalletManager_walletExists(wmPtr, walletInfo.walletName);
    if (!walletExist) {
      throw Exception("Given wallet doesn't exist (${walletInfo.walletName})");
    }
    final wptr =
        monero.WalletManager_openWallet(wmPtr, path: walletInfo.walletName, password: password);
    final status = monero.Wallet_status(wptr);
    if (status != 0) {
      final error = monero.Wallet_errorString(wptr);
      throw Exception(error);
    }
    CupcakeConfig.instance.lastWallet = walletInfo;
    CupcakeConfig.instance.save();
    return MoneroWallet(wptr);
  }

  @override
  Coins get type => Coins.monero;

  // monero.dart stuff
  static monero.WalletManager wmPtr = monero.WalletManagerFactory_getWalletManager();

  @override
  bool isSeedSomewhatLegit(final String seed) {
    final length = seed.split(" ").length;
    return [16, 25].contains(length);
  }

  @override
  WalletCreation creationMethod(final AppLocalizations L) => MoneroWalletCreation(L);
}
