import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/abstract.dart';

class OpenWalletViewModel extends ViewModel {
  OpenWalletViewModel({required this.coinInfo});

  CoinWalletInfo coinInfo;

  @override
  String get screenName => "Enter Password";
}
