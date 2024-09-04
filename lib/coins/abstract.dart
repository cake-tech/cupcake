import 'dart:core';

import 'package:flutter/cupertino.dart';

class CoinException implements Exception {
  CoinException(this.exception, {this.details});
  String exception;
  String? details;

  @override
  String toString() {
    return exception;
  }
}

typedef ProgressCallback = int Function({String? title, String? description});

enum Coins { monero, unknown }

class Coin {
  Coins get type => Coins.unknown;
  CoinStrings get strings => CoinStrings();

  bool get isEnabled => false;

  List<CoinWalletInfo> get coinWallets => [];
  Future<void> createNewWallet(
    String walletName,
    String walletPassword, {
    ProgressCallback? progressCallback,
  }) =>
      throw UnimplementedError("createNewWallet is not implemented");
}

class CoinWalletInfo {
  String get walletName => throw UnimplementedError();
  Coins get type => coin.type;
  Coin get coin => Coin();
  void open(BuildContext context) => throw UnimplementedError();
}

class CoinStrings {
  String get nameLowercase => "coin";
  String get nameCapitalized => "Coin";
  String get nameUppercase => "COIN";
  String get symbolLowercase => "coin";
  String get symbolUppercase => "COIN";
  String get nameFull => "$nameCapitalized ($symbolUppercase)";
}
