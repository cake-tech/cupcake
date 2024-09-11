import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/view_model/open_wallet_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class OpenWallet extends AbstractView {
  static Future<void> pushStatic(
      BuildContext context, CoinWalletInfo coin) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return OpenWallet(OpenWalletViewModel(coinInfo: coin));
        },
      ),
    );
  }

  OpenWallet(this.viewModel, {super.key});
  @override
  final OpenWalletViewModel viewModel;

  @override
  Widget body(BuildContext context) {
    return Column(children: [
      FormBuilder(formElements: [
        viewModel.walletPassword,
      ]),
    ]);
  }

  void _openWallet(BuildContext context) {
    callThrowable(
        context, () => viewModel.openWallet(context), "Opening wallet");
  }

  @override
  Widget? floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          callThrowable(context, () => _openWallet(context), "Opening wallet"),
    );
  }
}
