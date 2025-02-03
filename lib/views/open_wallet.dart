import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/view_model/open_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';

class OpenWallet extends AbstractView {
  OpenWallet({super.key, required CoinWalletInfo coinWalletInfo})
      : viewModel = OpenWalletViewModel(coinWalletInfo: coinWalletInfo);

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
          onLabelChange: viewModel.titleUpdate,
        ),
      ],
    );
  }
}
