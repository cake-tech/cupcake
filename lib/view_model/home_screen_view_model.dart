import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel({required this.openLastWallet, this.lastOpenedWallet});

  @override
  String get screenName => L.select_wallet;
  bool openLastWallet;

  String? lastOpenedWallet;

  Future<void> loadInitialState() async {
    await Future.delayed(Duration.zero); // load the screen
    if (CupcakeConfig.instance.lastWallet == null) return;
    if (mounted) return;
    if (!openLastWallet) return;
    if (CupcakeConfig.instance.lastWallet?.exists() != true) return;
    CupcakeConfig.instance.lastWallet!.openUI(c!);
  }

  Future<List<CoinWalletInfo>> get wallets async {
    List<CoinWalletInfo> wallets = [];
    for (var coin in walletCoins) {
      final toAdd = await coin.coinWallets;
      if (toAdd.isNotEmpty) {
        wallets.addAll(toAdd);
      }
    }
    if (CupcakeConfig.instance.walletSort == 0) {
      wallets.sort((a, b) => b.walletName.compareTo(a.walletName));
    } else if (CupcakeConfig.instance.walletSort == 1) {
      wallets.sort((a, b) => a.walletName.compareTo(b.walletName));
    }
    return wallets;
  }

  void toggleSort() {
    CupcakeConfig.instance.walletSort =
        (CupcakeConfig.instance.walletSort + 1) % 2;
    CupcakeConfig.instance.save();
    markNeedsBuild();
  }

  Future<bool> get showLandingInfo async => (await wallets).isEmpty;
}
