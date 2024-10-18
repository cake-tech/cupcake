import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/utils/config.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/home_screen_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/views/wallet_edit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// ignore: must_be_immutable
class HomeScreen extends AbstractView {
  HomeScreen({super.key, required this.viewModel});

  static Future<void> staticPush(BuildContext context,
      {bool openLastWallet = true, String? lastOpenedWallet}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return HomeScreen(
            viewModel: HomeScreenViewModel(
              openLastWallet: openLastWallet,
              lastOpenedWallet: lastOpenedWallet,
            ),
          );
        },
      ),
    );
  }

  @override
  final HomeScreenViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    return FutureBuilder(
      future: viewModel.showLandingInfo,
      builder: (BuildContext context, AsyncSnapshot<bool> value) {
        if (!value.hasData) return Container(); // TODO: placeholder?
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

  Widget walletsBody(
      BuildContext context, AsyncSnapshot<List<CoinWalletInfo>> wallets) {
    if (!wallets.hasData) return Container(); // TODO: placeholder?
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
                        onPressed: () {
                          callThrowable(
                            context,
                            () => renameWallet(context, wallets.data![index]),
                            "Renaming wallet",
                          );
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
    await WalletEdit.staticPush(context, walletInfo);
    await viewModel.markNeedsBuild();
  }

  Future<void> createWallet(BuildContext context, CreateMethod method) async {
    await CreateWallet.staticPush(
      context,
      CreateWalletViewModel(
        createMethod: method,
      ),
    );
    if (!context.mounted) return;
    markNeedsBuild(context);
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
  Future<void> initState(BuildContext context) async {
    await Future.delayed(Duration.zero); // load the screen
    if (config.lastWallet == null) return;
    if (!context.mounted) return;
    if (!viewModel.openLastWallet) return;
    config.lastWallet!.openUI(context);
  }
}
