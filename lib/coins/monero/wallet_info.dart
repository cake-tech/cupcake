import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/views/open_wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:monero/monero.dart' as monero;
import 'package:path/path.dart' as p;

class MoneroWalletInfo extends CoinWalletInfo {
  MoneroWalletInfo(String walletName)
      : _walletName = (() {
          if (walletName == p.basename(walletName)) {
            walletName = p.join(Monero.baseDir.path, walletName);
          }
          return walletName;
        }());

  @override
  Coin get coin => Monero();

  @override
  Future<bool> checkWalletPassword(String password) async {
    return monero.WalletManager_verifyWalletPassword(
      Monero.wmPtr,
      keysFileName: "$walletName.keys",
      password: password,
      noSpendKey: false,
      kdfRounds: 0,
    );
  }

  @override
  String get walletName => _walletName;

  String _walletName;

  @override
  Coins get type => coin.type;

  @override
  void openUI(BuildContext context) {
    OpenWallet(coinWalletInfo: this).push(context);
  }

  @override
  Future<CoinWallet> openWallet(BuildContext context,
      {required String password}) async {
    return await coin.openWallet(
      this,
      password: password,
    );
  }

  @override
  Future<void> deleteWallet() async {
    for (var element in Monero.wPtrList) {
      monero.WalletManager_closeWallet(Monero.wmPtr, element, true);
    }
    Monero.wPtrList.clear();
    File(walletName).deleteSync();
    File("$walletName.keys").deleteSync();
  }

  @override
  Future<void> renameWallet(String newName) async {
    if (p.basename(walletName) == newName) {
      throw Exception("Wallet wasn't renamed");
    }
    for (var element in Monero.wPtrList) {
      monero.WalletManager_closeWallet(Monero.wmPtr, element, true);
    }
    Monero.wPtrList.clear();
    final basePath = p.dirname(walletName);
    File(walletName).copySync(p.join(basePath, newName));
    File("$walletName.keys").copySync(p.join(basePath, "$newName.keys"));
    File(walletName).deleteSync();
    File("$walletName.keys").deleteSync();
    _walletName = newName;
  }

  @override
  bool exists() => File("$walletName.keys").existsSync();
}
