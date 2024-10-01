import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/abstract.dart';

class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(this.wallet);
  CoinWallet wallet;

  @override
  String get screenName => "Receive";

  String get address => wallet.getCurrentAddress;
}
