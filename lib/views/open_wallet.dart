import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/view_model/open_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';

class OpenWallet extends AbstractView {
  OpenWallet({
    super.key,
    required final CoinWalletInfo coinWalletInfo,
  }) : viewModel = OpenWalletViewModel(
          coinWalletInfo: coinWalletInfo,
        );

  @override
  final OpenWalletViewModel viewModel;

  @override
  Widget body(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FormBuilder(
          showExtra: false,
          viewModel: FormBuilderViewModel(
            formElements: [
              viewModel.walletPassword,
            ],
            scaffoldContext: context,
            isPinSet: false,
            toggleIsPinSet: (final bool val) {},
            onLabelChange: (final String? _) {},
          ),
        ),
      ],
    );
  }
}
