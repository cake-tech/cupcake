import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/wallet_home_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// ignore: must_be_immutable
class WalletHome extends AbstractView {
  WalletHome({super.key, required CoinWallet coinWallet})
      : viewModel = WalletHomeViewModel(wallet: coinWallet);

  static Future<void> pushStatic(BuildContext context, CoinWallet coin) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return WalletHome(coinWallet: coin);
        },
      ),
    );
  }

  @override
  final WalletHomeViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [Text(viewModel.balance),
      SelectableText(viewModel.currentAddress)],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body(context),
      floatingActionButton: floatingActionButton(context),
    );
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => viewModel.showScanner(context),
      child: const Icon(Icons.scanner),
    );
  }

  @override
  // TODO: implement appBar
  AppBar get appBar => AppBar(
    title: Text(viewModel.screenName),
    actions: [
      IconButton(
        iconSize: 32.0,
        icon: const Icon(Icons.settings),
        onPressed: () async {
        },
      ),
    ],
  );
}
