import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/abstract.dart';

class ReceiveViewModel extends ViewModel {
  ReceiveViewModel(this.wallet);
  CoinWallet wallet;

  @override
  String get screenName => L.receive;

  String get address => wallet.getCurrentAddress;
}
