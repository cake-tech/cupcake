import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/zcash/creation/common.dart';
import 'package:cupcake/coins/zcash/strings.dart';
import 'package:cupcake/coins/zcash/utils.dart';
import 'package:cupcake/coins/zcash/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart' as p;

class Zcash implements Coin {
  static final baseDir = Directory(p.join(baseStoragePath, ZcashStrings().symbolLowercase));

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final List<CoinWalletInfo> retWallets = [];
    final list = baseDir.listSync(recursive: true, followLinks: true);
    for (final element in list) {
      if (p.basename(element.absolute.path) == "zcash.keys") {
        final dirname = p.dirname(element.absolute.path);
        retWallets.add(ZcashWalletInfo(p.basename(dirname)));
      }
    }
    return Future.value(retWallets);
  }

  @override
  WalletCreation creationMethod(final AppLocalizations L) => ZcashWalletCreation(L);
  @override
  Map<String, dynamic Function(BuildContext context, CoinWallet wallet)> get debugOptions => {};

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
    final walletDir = Directory(walletPath);
    if (!walletDir.existsSync()) {
      walletDir.createSync(recursive: true);
    }
    return walletPath;
  }

  @override
  bool get isEnabled => true;

  @override
  bool isSeedSomewhatLegit(final String seed) {
    return [12, 24].contains(seed.split(" ").length);
  }

  @override
  Future<CoinWallet> openWallet(
    final CoinWalletInfo walletInfo, {
    required final String password,
  }) async {
    final u = ZcashUtils(
      password: password,
      walletName: walletInfo.walletName,
    );
    await u.init();
    return u.wallet;
  }

  @override
  CoinStrings get strings => ZcashStrings();

  @override
  Coins get type => Coins.zcash;

  @override
  String get uriScheme => "zcash";
}
