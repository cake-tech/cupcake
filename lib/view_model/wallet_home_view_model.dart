import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/abstract.dart';
import 'package:cup_cake/views/barcode_scanner.dart';
import 'package:flutter/cupertino.dart';

class WalletHomeViewModel extends ViewModel {
  WalletHomeViewModel({required this.wallet});

  final CoinWallet wallet;

  @override
  late String screenName = wallet.coin.strings.nameFull;

  String get balance => wallet.getBalanceString();

  void showScanner(BuildContext context) {
    BarcodeScanner().push(context);
  }

}
