import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/zcash/coin.dart';
import 'package:cupcake/coins/zcash/utils.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/views/open_wallet.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart' as p;

class ZcashWalletInfo extends CoinWalletInfo {
  ZcashWalletInfo(this.walletName) : super();

  @override
  final String walletName;

  File get _keyFile => File(p.join(Zcash.baseDir.path, walletName, "zcash.keys"));

  Directory get _walletDir => Directory(p.join(Zcash.baseDir.path, walletName));

  @override
  Future<bool> checkWalletPassword(final String password) async {
    try {
      DefaultEncryption().decryptBytes(_keyFile.readAsBytesSync(), password);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Coin get coin => Zcash();

  @override
  Future<void> deleteWallet() async {
    if (_walletDir.existsSync()) {
      _walletDir.deleteSync(recursive: true);
    }
  }

  @override
  bool exists() => _keyFile.existsSync();

  @override
  Future<void> openUI(final BuildContext context) {
    return OpenWallet(coinWalletInfo: this, enableBiometric: false).push(context);
  }

  @override
  Future<CoinWallet> openWallet(
    final BuildContext context, {
    required final String password,
  }) async {
    await ZcashUtils.globalInit();
    final u = ZcashUtils(password: password, walletName: walletName);
    await u.init();
    return u.wallet;
  }

  @override
  Future<void> renameWallet(final String newName) async {
    if (walletName == newName) {
      throw Exception(Coin.L.error_wallet_name_unchanged);
    }
    final destPath = p.normalize(p.join(Zcash.baseDir.path, newName));
    if (!destPath.startsWith(p.normalize(Zcash.baseDir.path))) {
      throw Exception(Coin.L.error_illegal_wallet_name(newName));
    }
    if (Directory(destPath).existsSync()) {
      throw Exception(Coin.L.error_wallet_name_already_exists);
    }
    _walletDir.renameSync(destPath);
  }

  @override
  Coins get type => Coins.zcash;
}
