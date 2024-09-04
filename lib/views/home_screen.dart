import 'package:cup_cake/view_model/home_screen_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/create_wallet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

// ignore: must_be_immutable
class HomeScreen extends AbstractView {
  HomeScreen({super.key});

  @override
  Future<void> push(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return HomeScreen();
        },
      ),
    );
  }

  @override
  final HomeScreenViewModel viewModel = HomeScreenViewModel();

  @override
  Widget? body(BuildContext context) {
    if (viewModel.showLandingInfo) {
      return const Text("You don't have any wallets, consider creating one.");
    }
    return ListView.builder(
      itemCount: viewModel.wallets.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            viewModel.wallets[index].open(context);
          },
          child: Card(
            child: ListTile(
              title: Text(
                p.basename(viewModel.wallets[index].walletName),
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
      child: const Icon(Icons.add),
      onPressed: () async {
        await CreateWallet().push(context);
        if (!context.mounted) return;
        markNeedsBuild(context);
      },
    );
  }
}
