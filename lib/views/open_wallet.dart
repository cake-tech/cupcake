import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/view_model/open_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';

class OpenWallet extends AbstractView {
  OpenWallet({
    super.key,
    required final CoinWalletInfo coinWalletInfo,
    required final bool enableBiometric,
  }) : viewModel = OpenWalletViewModel(
          coinWalletInfo: coinWalletInfo,
          enableBiometric: enableBiometric,
        );

  @override
  final OpenWalletViewModel viewModel;

  @override
  Widget body(final BuildContext context) {
    return FormBuilder(
      showExtra: false,
      viewModel: viewModel.formBuilderViewModel,
    );
  }
}
