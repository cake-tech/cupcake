import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/litecoin/coin.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/views/open_wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;

class LitecoinWalletInfo extends CoinWalletInfo {
  LitecoinWalletInfo(String walletName)
      : _walletName = (() {
          if (walletName == p.basename(walletName)) {
            walletName = p.join(Litecoin.baseDir.path, walletName);
          }
          if (walletName.endsWith('.keys')) {
            walletName = walletName.substring(0, walletName.length - 5);
          }
          return walletName;
        }());

  @override
  Coin get coin => Litecoin();

  @override
  Future<bool> checkWalletPassword(final String password) async {
    final encrypted = File("$walletName.keys").readAsBytesSync();
    try {
      DefaultEncryption().decryptBytes(encrypted, password);
      return true;
    } catch (e) {
      return false;
    }
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
    File("$walletName.keys").deleteSync();
    return Future.value();
  }

  @override
  Future<void> renameWallet(final String newName) async {
    if (p.basename(walletName) == newName) {
      throw Exception(Coin.L.error_wallet_name_unchanged);
    }
    final basePath = p.dirname(walletName);
    if (File(p.join(basePath, newName)).existsSync()) {
      throw Exception(Coin.L.error_wallet_name_already_exists);
    }
    File(walletName).copySync(p.join(basePath, newName));
    // Copy and delete later, if anything throws below we end up with copied walled,
    // instead of nuking the wallet
    File(walletName).deleteSync();
    File("$walletName.keys").deleteSync();
    _walletName = newName;
  }

  @override
  bool exists() => File(walletName).existsSync();
}
