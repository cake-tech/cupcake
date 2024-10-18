import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/view_model/abstract.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel();

  @override
  String get screenName => L.wallet_details;

  Future<List<CoinWalletInfo>> get wallets async {
    List<CoinWalletInfo> wallets = [];
    for (var coin in walletCoins) {
      final toAdd = await coin.coinWallets;
      if (toAdd.isNotEmpty) {
        wallets.addAll(toAdd);
      }
    }
    return wallets;
  }

  Future<bool> get showLandingInfo async => (await wallets).isEmpty;
}
