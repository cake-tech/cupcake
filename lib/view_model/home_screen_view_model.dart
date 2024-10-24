import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel({required this.openLastWallet, this.lastOpenedWallet});

  @override
  String get screenName => L.select_wallet;
  bool openLastWallet;

  String? lastOpenedWallet;

  Future<List<CoinWalletInfo>> get wallets async {
    List<CoinWalletInfo> wallets = [];
    for (var coin in walletCoins) {
      final toAdd = await coin.coinWallets;
      if (toAdd.isNotEmpty) {
        wallets.addAll(toAdd);
      }
    }
    if (config.walletSort == 0) {
      wallets.sort((a, b) => b.walletName.compareTo(a.walletName));
    } else if (config.walletSort == 1) {
      wallets.sort((a, b) => a.walletName.compareTo(b.walletName));
    }
    return wallets;
  }

  void toggleSort() {
    config.walletSort = (config.walletSort + 1) % 2;
    config.save();
    markNeedsBuild();
  }

  Future<bool> get showLandingInfo async => (await wallets).isEmpty;
}
