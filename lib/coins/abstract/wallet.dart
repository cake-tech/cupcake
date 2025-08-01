import 'package:cupcake/coins/abstract/coin.dart';
import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/abstract/wallet_seed_detail.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:flutter/widgets.dart';

abstract class CoinWallet {
  CoinWallet();

  Coin get coin;

  Future<void> handleUR(final BuildContext context, final URQRData ur) =>
      throw UnimplementedError();

  List<String> get connectCakeWalletQRCode;

  bool get hasAccountSupport;

  bool get hasAddressesSupport;

  int getAccountsCount();

  void setAccount(final int accountIndex);

  int getAccountId();

  int get addressIndex;

  String get getAccountLabel;

  String get getCurrentAddress;

  String get seed;

  String get passphrase;

  String get primaryAddress;

  String get walletName;

  int getBalance();

  String getBalanceString();

  Future<void> close();

  CoinWalletInfo get walletInfo;

  Future<List<WalletSeedDetail>> seedDetails() => throw UnimplementedError();
}
