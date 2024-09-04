import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/list.dart';
import 'package:cup_cake/view_model/abstract.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel();

  @override
  String get screenName => "Select Wallet";

  List<CoinWalletInfo> get wallets {
    List<CoinWalletInfo> wallets = [];
    for (var coin in walletCoins) {
      wallets.addAll(coin.coinWallets);
    }
    return wallets;
  }

  bool get showLandingInfo => wallets.isEmpty;
}
