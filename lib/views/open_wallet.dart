import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/view_model/open_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';

// ignore: must_be_immutable
class OpenWallet extends AbstractView {
  static Future<void> pushStatic(
      BuildContext context, CoinWalletInfo coin) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return OpenWallet(
            OpenWalletViewModel(
              coinInfo: coin,
            ),
          );
        },
      ),
    );
  }

  OpenWallet(this.viewModel, {super.key});
  @override
  final OpenWalletViewModel viewModel;

  @override
  Widget body(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FormBuilder(
          formElements: [
            viewModel.walletPassword,
          ],
          scaffoldContext: context,
          isPinSet: false,
          showExtra: false,
        ),
      ],
    );
  }
}
