import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/coins/list.dart';
import 'package:cup_cake/view_model/abstract.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel();

  @override
  String get screenName => "Select Wallet";

  Future<List<CoinWalletInfo>> get wallets async {
    List<CoinWalletInfo> wallets = [];
    for (var coin in walletCoins) {
      wallets.addAll(await coin.coinWallets);
    }
    return wallets;
  }

  Future<bool> get showLandingInfo async => (await wallets).isEmpty;
}
