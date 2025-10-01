import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/views/open_wallet.dart';
import 'package:flutter/cupertino.dart';
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
  Future<bool> checkWalletPassword(final String password) async {
    return Monero.wm.verifyWalletPassword(
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
  Future<void> openUI(final BuildContext context) {
    return OpenWallet(coinWalletInfo: this, enableBiometric: false).push(context);
  }

  @override
  Future<CoinWallet> openWallet(
    final BuildContext context, {
    required final String password,
  }) {
    return coin.openWallet(
      this,
      password: password,
    );
  }

  @override
  Future<void> deleteWallet() {
    for (final element in Monero.wPtrList) {
      Monero.wm.closeWallet(element, true);
    }
    Monero.wPtrList.clear();
    File(walletName).deleteSync();
    File("$walletName.keys").deleteSync();
    return Future.value();
  }

  @override
  Future<void> renameWallet(final String newName) async {
    if (p.basename(walletName) == newName) {
      throw Exception(Coin.L.error_wallet_name_unchanged);
    }
    for (final element in Monero.wPtrList) {
      Monero.wm.closeWallet(element, true);
    }
    Monero.wPtrList.clear();
    final basePath = p.dirname(walletName);
    if (File(p.join(basePath, newName)).existsSync()) {
      throw Exception(Coin.L.error_wallet_name_already_exists);
    }
    if (File(p.join(basePath, "$newName.keys")).existsSync()) {
      throw Exception(Coin.L.error_wallet_name_already_exists);
    }
    File(walletName).copySync(p.join(basePath, newName));
    File("$walletName.keys").copySync(p.join(basePath, "$newName.keys"));

    // Copy and delete later, if anything throws below we end up with copied walled,
    // instead of nuking the wallet
    File(walletName).deleteSync();
    File("$walletName.keys").deleteSync();
    _walletName = newName;
  }

  @override
  bool exists() => File("$walletName.keys").existsSync();
}
