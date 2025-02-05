import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/coins/types.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/home_screen_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/views/wallet_edit.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class HomeScreen extends AbstractView {
  HomeScreen(
      {super.key, required bool openLastWallet, String? lastOpenedWallet})
      : viewModel = HomeScreenViewModel(
            openLastWallet: openLastWallet, lastOpenedWallet: lastOpenedWallet);

  @override
  final HomeScreenViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    return FutureBuilder(
      future: viewModel.showLandingInfo,
      builder: (BuildContext context, AsyncSnapshot<bool> value) {
        if (!value.hasData) return Container();
        if (value.data!) {
          return Text(L.home_no_wallets);
        }
        return FutureBuilder(
          future: viewModel.wallets,
          builder: walletsBody,
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
      BuildContext context, AsyncSnapshot<List<CoinWalletInfo>> wallets) {
    if (!wallets.hasData) return Container();
    return ListView.builder(
        itemCount: wallets.data!.length,
        itemBuilder: (BuildContext context, int index) {
          bool isOpen = (wallets.data![index].walletName)
              .contains(viewModel.lastOpenedWallet ?? "");
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
                        wallets.data![index].openUI(context);
                      },
                      leading: SizedBox(
                        width: 32,
                        child: wallets.data![index].coin.strings.svg,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () async {
                          await callThrowable(
                            context,
                            () => renameWallet(context, wallets.data![index]),
                            "Renaming wallet",
                          );
                          viewModel.markNeedsBuild();
                        },
                      ),
                      title: Text(
                        p.basename(wallets.data![index].walletName),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> renameWallet(
      BuildContext context, CoinWalletInfo walletInfo) async {
    canPop = false; // don't allow user to go back to previous wallet
    await viewModel.markNeedsBuild();
    if (!context.mounted) return;
    await WalletEdit(walletInfo: walletInfo).push(context);
    await viewModel.markNeedsBuild();
  }

  Future<void> createWallet(BuildContext context, CreateMethod method) async {
    await CreateWallet(
      createMethod: method,
      needsPasswordConfirm: false,
    ).push(context);
    if (!context.mounted) return;
    viewModel.markNeedsBuild();
  }

  @override
  Widget? bottomNavigationBar(BuildContext context) {
    return SafeArea(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LongPrimaryButton(
          icon: Icons.add,
          onPressed: () => createWallet(context, CreateMethod.create),
          text: L.create_new_wallet,
        ),
        LongSecondaryButton(
          icon: Icons.restore,
          onPressed: () => createWallet(context, CreateMethod.restore),
          text: L.restore_wallet,
        ),
      ],
    ));
  }

  @override
  Future<void> initState(BuildContext context) {
    return viewModel.loadInitialState();
  }
}
