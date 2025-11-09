import 'dart:async';
import 'dart:io';

import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/strings.dart';
import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/coins/abstract/wallet_creation.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/litecoin/creation/common.dart';
import 'package:cupcake/coins/litecoin/strings.dart';
import 'package:cupcake/coins/litecoin/wallet.dart';
import 'package:cupcake/coins/litecoin/wallet_info.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/encryption/default.dart';
import 'package:cupcake/utils/filesystem.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class Litecoin implements Coin {
  Litecoin();
  @override
  String get uriScheme => 'litecoin';

  @override
  bool get isEnabled => true;

  @override
  CoinStrings get strings => LitecoinStrings();

  static final baseDir = Directory(p.join(baseStoragePath, LitecoinStrings().symbolLowercase));

  @override
  Future<List<CoinWalletInfo>> get coinWallets {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }
    final List<CoinWalletInfo> retWallets = [];
    final list = baseDir.listSync(recursive: true, followLinks: true);
    for (final element in list) {
      if (!element.absolute.path.endsWith(".keys")) continue;
      retWallets.add(LitecoinWalletInfo(element.absolute.path));
    }
    return Future.value(retWallets);
  }

  @override
  String getPathForWallet(final String walletName) {
    if (!baseDir.existsSync()) {
      baseDir.createSync(recursive: true);
    }

    // Prevent user from slipping outside allowed directory
    final String walletPath = p.join(baseDir.path, walletName);
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
    final encrypted = File("${walletInfo.walletName}.keys").readAsBytesSync();
    final data = DefaultEncryption().decryptString(encrypted, password);
    final mnemonic = data.split(";")[0];
    final passphrase = data.contains(";") ? data.substring(data.indexOf(";") + 1) : "";
    return LitecoinWallet(
      seed: mnemonic,
      passphrase: passphrase,
      walletName: walletInfo.walletName,
    );
  }

  @override
  Coins get type => Coins.litecoin;

  @override
  bool isSeedSomewhatLegit(final String seed) {
    final length = seed.split(" ").length;
    return [12, 18, 24].contains(length);
  }

  @override
  WalletCreation creationMethod(final AppLocalizations L) => LitecoinWalletCreation(L);

  @override
  Map<String, Function(BuildContext context, CoinWallet wallet)> debugOptions = {};
}
