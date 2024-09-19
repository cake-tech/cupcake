import 'dart:core';

import 'package:cup_cake/view_model/barcode_scanner_view_model.dart';
import 'package:flutter/cupertino.dart';

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

class Coin {
  Coins get type => Coins.unknown;
  CoinStrings get strings => CoinStrings();

  bool get isEnabled => false;

  Future<List<CoinWalletInfo>> get coinWallets => Future.value([]);

  Future<void> createNewWallet(
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
  }) =>
      throw UnimplementedError("createNewWallet is not implemented");
  Future<CoinWallet> openWallet(String walletName,
          {required String password}) =>
      throw UnimplementedError();
}

class CoinWalletInfo {
  String get walletName => throw UnimplementedError();
  Coins get type => coin.type;
  Coin get coin => Coin();
  void openUI(BuildContext context) => throw UnimplementedError();

  Future<CoinWallet> openWallet(BuildContext context,
          {required String password}) =>
      throw UnimplementedError();
}

class CoinStrings {
  String get nameLowercase => "coin";
  String get nameCapitalized => "Coin";
  String get nameUppercase => "COIN";
  String get symbolLowercase => "coin";
  String get symbolUppercase => "COIN";
  String get nameFull => "$nameCapitalized ($symbolUppercase)";
}

class CoinWallet {
  CoinWallet();

  Coin coin = Coin();
  Future<void> handleUR(BuildContext context, URQRData ur) =>
      throw UnimplementedError();
  bool get hasAccountSupport => false;
  bool get hasAddressesSupport => false;

  int getAccountsCount() => throw UnimplementedError();
  void setAccount(int accountIndex) => throw UnimplementedError();
  int getAccountId() => throw UnimplementedError();

  int get addressIndex => throw UnimplementedError();
  String get getAccountLabel => throw UnimplementedError();
  String get getCurrentAddress => throw UnimplementedError();

  int getBalance() => throw UnimplementedError();
  String getBalanceString() => throw UnimplementedError();
}
