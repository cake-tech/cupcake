import 'dart:core';

import 'package:cupcake/coins/monero/coin.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/barcode_scanner_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path/path.dart' as p;

class CoinException implements Exception {
  CoinException(this.exception, {this.details});

  String exception;
  String? details;

  @override
  String toString() {
    return "$exception\n$details";
  }
}

typedef ProgressCallback = int Function({String? title, String? description});

enum Coins { monero, unknown }

abstract class Coin {
  Coins get type => Coins.unknown;

  CoinStrings get strings;

  bool get isEnabled;

  Future<List<CoinWalletInfo>> get coinWallets;

  Future<CoinWallet> createNewWallet(
    String walletName,
    String walletPassword, {
    ProgressCallback? progressCallback,
    required bool? createWallet,
    required String? seed,
    required int? restoreHeight,
    required String? primaryAddress,
    required String? viewKey,
    required String? spendKey,
    required String? seedOffsetOrEncryption,
  });

  Future<CoinWallet> openWallet(CoinWalletInfo walletInfo, {required String password});
}

abstract class CoinWalletInfo {
  String get walletName;

  Coins get type => coin.type;

  Coin get coin;

  void openUI(BuildContext context);

  Future<bool> checkWalletPassword(String password);

  Future<CoinWallet> openWallet(BuildContext context, {required String password});

  Map<String, dynamic> toJson() {
    return {
      "typeIndex": type.index,
      if (config.debug) "typeIndex__debug": type.toString(),
      "walletName": p.basename(walletName),
    };
  }

  static CoinWalletInfo? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final type = Coins.values[json["typeIndex"] as int];
    final walletName = (json["walletName"] as String);
    switch (type) {
      case Coins.monero:
        return MoneroWalletInfo(walletName);
      case Coins.unknown:
        throw UnimplementedError("unknown coin");
    }
  }

  Future<void> deleteWallet();

  Future<void> renameWallet(String newName);
}

abstract class CoinStrings {
  String get nameLowercase => "coin";
  String get nameCapitalized => "Coin";
  String get nameUppercase => "COIN";
  String get symbolLowercase => "coin";
  String get symbolUppercase => "COIN";
  String get nameFull => "$nameCapitalized ($symbolUppercase)";

  SvgPicture get svg;
}

enum WalletSeedDetailType {
  text,
  qr,
}

class WalletSeedDetail {
  WalletSeedDetail({
    required this.type,
    required this.name,
    required this.value,
  });

  final WalletSeedDetailType type;
  final String name;
  final String value;
}

abstract class CoinWallet {
  CoinWallet();

  Coin get coin;

  Future<void> handleUR(BuildContext context, URQRData ur) => throw UnimplementedError();

  bool get hasAccountSupport => false;

  bool get hasAddressesSupport => false;

  int getAccountsCount();

  void setAccount(int accountIndex);

  int getAccountId();

  int get addressIndex;

  String get getAccountLabel;

  String get getCurrentAddress;

  String get seed;

  String get primaryAddress;

  String get walletName;

  int getBalance();

  String getBalanceString();

  Future<void> close();

  Future<List<WalletSeedDetail>> seedDetails(AppLocalizations L) => throw UnimplementedError();
}
