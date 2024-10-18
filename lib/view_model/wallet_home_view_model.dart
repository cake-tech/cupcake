import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/barcode_scanner.dart';
import 'package:flutter/cupertino.dart';

class WalletHomeViewModel extends ViewModel {
  WalletHomeViewModel({required this.wallet});

  final CoinWallet wallet;
  Coin get coin => wallet.coin;

  @override
  late String screenName = "Cupcake";

  String get balance => wallet.getBalanceString();
  String get currentAddress => wallet.getCurrentAddress;

  void showScanner(BuildContext context) {
    BarcodeScanner.pushStatic(context, wallet);
  }
}
