import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/list.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/wallet_edit.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'home_screen_view_model.g.dart';

class HomeScreenViewModel = HomeScreenViewModelBase with _$HomeScreenViewModel;

abstract class HomeScreenViewModelBase extends ViewModel with Store {
  HomeScreenViewModelBase({
    required this.openLastWallet,
    this.lastOpenedWallet,
  });

  @override
  String get screenName => "Cupcake";

  final bool openLastWallet;

  final String? lastOpenedWallet;

  @action
  Future<void> renameWallet(final CoinWalletInfo walletInfo) async {
    canPop = false; // don't allow user to go back to previous wallet
    if (!mounted) return;
    return WalletEdit(walletInfo: walletInfo).push(c!);
  }

  Future<void> createWallet(final CreateMethod method) async {
    if (!mounted) return;
    return CreateWallet(
      createMethod: method,
      needsPasswordConfirm: false,
    ).push(c!);
  }

  Future<void> loadInitialState(final BuildContext context) async {
    await Future.delayed(Duration.zero); // load the screen
    if (CupcakeConfig.instance.lastWallet == null) return;
    if (!context.mounted) return;
    if (!openLastWallet) return;
    if (CupcakeConfig.instance.lastWallet?.exists() != true) return;
    return CupcakeConfig.instance.lastWallet!.openUI(context);
  }

  Future<List<CoinWalletInfo>> wallets(final int sort) async {
    final List<CoinWalletInfo> wallets = [];
    for (final coin in walletCoins) {
      final toAdd = await coin.coinWallets;
      if (toAdd.isNotEmpty) {
        wallets.addAll(toAdd);
      }
    }
    if (sort == 0) {
      wallets.sort((final a, final b) => b.walletName.compareTo(a.walletName));
    } else if (sort == 1) {
      wallets.sort((final a, final b) => a.walletName.compareTo(b.walletName));
    }
    return wallets;
  }

  @observable
  int varWalletSort = CupcakeConfig.instance.walletSort;

  set walletSort(final int value) {
    varWalletSort = value;
    CupcakeConfig.instance.walletSort = value;
    CupcakeConfig.instance.save();
  }

  @action
  void toggleSort() {
    walletSort = (varWalletSort + 1) % 2;
  }

  @computed
  Future<bool> get showLandingInfo async => (await wallets(varWalletSort)).isEmpty;
}
