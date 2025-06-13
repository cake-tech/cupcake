import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/utils/types.dart';
import 'package:cupcake/view_model/home_screen_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends AbstractView {
  HomeScreen({
    super.key,
    required final bool openLastWallet,
    final String? lastOpenedWallet,
  }) : viewModel = HomeScreenViewModel(
          openLastWallet: openLastWallet,
          lastOpenedWallet: lastOpenedWallet,
        );

  @override
  final HomeScreenViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return FutureBuilder(
      future: viewModel.showLandingInfo,
      builder: (final BuildContext context, final AsyncSnapshot<bool> value) {
        if (!value.hasData) return Container();
        if (value.data!) {
          return Text(L.home_no_wallets);
        }
        return FutureBuilder(
          future: viewModel.wallets(viewModel.varWalletSort),
          builder: (
            final BuildContext context,
            final AsyncSnapshot<List<CoinWalletInfo>> wallets,
          ) {
            return walletsBody(context, wallets);
          },
        );
      },
    );
  }

  @override
  AppBar? get appBar => AppBar(
        title: Text(
          viewModel.screenName,
          style: const TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: canPop,
        actions: [
          IconButton(
            onPressed: viewModel.toggleSort,
            icon: const Icon(Icons.sort),
          ),
        ],
      );
  Widget walletsBody(
    final BuildContext context,
    final AsyncSnapshot<List<CoinWalletInfo>> wallets,
  ) {
    if (!wallets.hasData) return Container();
    return ListView.builder(
      itemCount: wallets.data!.length,
      itemBuilder: (final BuildContext context, final int index) {
        final bool isOpen =
            (wallets.data![index].walletName).contains(viewModel.lastOpenedWallet ?? "");
        return singleWalletWidget(context, isOpen, wallets.data![index]);
      },
    );
  }

  Card singleWalletWidget(
    final BuildContext context,
    final bool isOpen,
    final CoinWalletInfo wallet,
  ) {
    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              color: isOpen ? Colors.blue : Colors.transparent,
              height: double.infinity,
            ),
            Expanded(
              child: ListTile(
                onTap: () {
                  wallet.openUI(context);
                },
                leading: SizedBox(
                  width: 32,
                  child: wallet.coin.strings.svg,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => viewModel.renameWallet(wallet),
                ),
                title: Text(
                  p.basename(wallet.walletName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LongPrimaryButton(
            icon: Icons.add,
            onPressed: () => viewModel.createWallet(CreateMethod.create),
            text: L.create_new_wallet,
          ),
          LongSecondaryButton(
            icon: Icons.restore,
            onPressed: () => viewModel.createWallet(CreateMethod.restore),
            text: L.restore_wallet,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> initState(final BuildContext context) {
    return viewModel.loadInitialState(context);
  }
}
