import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/config.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/view_model/home_screen_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/create_wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// ignore: must_be_immutable
class HomeScreen extends AbstractView {
  HomeScreen({super.key, required this.viewModel});

  static Future<void> staticPush(BuildContext context,
      {bool openLastWallet = true}) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return HomeScreen(
              viewModel: HomeScreenViewModel(openLastWallet: openLastWallet));
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
        return InkWell(
          onTap: () {
            wallets.data![index].openUI(context);
          },
          child: Card(
            child: ListTile(
              title: Text(
                p.basename(wallets.data![index].walletName),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () async {
        await CreateWallet.staticPush(
          context,
          CreateWalletViewModel(
            createMethod: CreateMethod.any,
          ),
        );
        if (!context.mounted) return;
        markNeedsBuild(context);
      },
    );
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
