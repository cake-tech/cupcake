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
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:monero/src/monero.dart' as api;
import 'package:monero/src/wallet2.dart';
import 'package:monero/monero.dart' as monero;

class Monero implements Coin {
  Monero();
  static List<Wallet2Wallet> wPtrList = [];

  @override
  String get uriScheme => 'monero';

  @override
  bool get isEnabled {
    try {
      // ignore: deprecated_member_use
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
      if (!wm.walletExists(element.absolute.path)) {
        continue;
      }
      retWallets.add(MoneroWalletInfo(element.absolute.path));
    }
    return Future.value(retWallets);
  }

  @override
  String getPathForWallet(final String walletName) {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    // Prevent user from slipping outside allowed directory
    final String walletPath = p.normalize(p.join(baseDir.path, walletName));
    if (!walletPath.startsWith(baseDir.path)) {
      throw Exception(Coin.L.error_illegal_wallet_name(walletName));
    }
    return walletPath;
  }

  @override
  Future<CoinWallet> openWallet(
    final CoinWalletInfo walletInfo, {
    required final String password,
  }) async {
    for (final wptr in wPtrList) {
      wm.closeWallet(wptr, true);
    }
    wPtrList.clear();
    final walletExist = wm.walletExists(walletInfo.walletName);
    if (!walletExist) {
      throw Exception(Coin.L.error_wallet_doesnt_exist(walletInfo.walletName));
    }
    final w = wm.openWallet(path: walletInfo.walletName, password: password);
    final status = w.status();
    if (status != 0) {
      final error = w.errorString();
      throw Exception(error);
    }
    return MoneroWallet(w);
  }

  @override
  Coins get type => Coins.monero;

  // monero.dart stuff
  static Wallet2WalletManager wm = api.MoneroWalletManagerFactory().getWalletManager();

  @override
  bool isSeedSomewhatLegit(final String seed) {
    final length = seed.split(" ").length;
    return [16, 25].contains(length);
  }

  @override
  WalletCreation creationMethod(final AppLocalizations L) => MoneroWalletCreation(L);

  @override
  Map<String, Function(BuildContext context, CoinWallet wallet)> debugOptions = {};
}
