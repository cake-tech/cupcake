import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/coins/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/wallet_edit.dart';
import 'package:flutter/material.dart';

class HomeScreenViewModel extends ViewModel {
  HomeScreenViewModel({required this.openLastWallet, this.lastOpenedWallet});

  @override
  String get screenName => L.select_wallet;
  final bool openLastWallet;

  final String? lastOpenedWallet;

  Future<void> renameWallet(final CoinWalletInfo walletInfo) async {
    canPop = false; // don't allow user to go back to previous wallet
    markNeedsBuild();
    if (!mounted) return;
    await WalletEdit(walletInfo: walletInfo).push(c!);
    markNeedsBuild();
  }

  Future<void> createWallet(final CreateMethod method) async {
    if (!mounted) return;
    await CreateWallet(
      createMethod: method,
      needsPasswordConfirm: false,
    ).push(c!);
    markNeedsBuild();
  }

  Future<void> loadInitialState(final BuildContext context) async {
    await Future.delayed(Duration.zero); // load the screen
    if (CupcakeConfig.instance.lastWallet == null) return;
    if (!context.mounted) return;
    if (!openLastWallet) return;
    if (CupcakeConfig.instance.lastWallet?.exists() != true) return;
    CupcakeConfig.instance.lastWallet!.openUI(context);
  }

  Future<List<CoinWalletInfo>> get wallets async {
    final List<CoinWalletInfo> wallets = [];
    for (final coin in walletCoins) {
      final toAdd = await coin.coinWallets;
      if (toAdd.isNotEmpty) {
        wallets.addAll(toAdd);
      }
    }
    if (CupcakeConfig.instance.walletSort == 0) {
      wallets.sort((final a, final b) => b.walletName.compareTo(a.walletName));
    } else if (CupcakeConfig.instance.walletSort == 1) {
      wallets.sort((final a, final b) => a.walletName.compareTo(b.walletName));
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
