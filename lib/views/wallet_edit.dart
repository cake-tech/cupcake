import 'package:cupcake/coins/abstract/wallet_info.dart';
import 'package:cupcake/view_model/form_builder_view_model.dart';
import 'package:cupcake/view_model/wallet_edit_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/form_builder.dart';
import 'package:flutter/material.dart';

class WalletEdit extends AbstractView {
  WalletEdit({
    super.key,
    required final CoinWalletInfo walletInfo,
  }) : viewModel = WalletEditViewModel(
          walletInfo: walletInfo,
        );

  @override
  WalletEditViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        FormBuilder(
          showExtra: true,
          viewModel: FormBuilderViewModel(
            formElements: viewModel.form,
            scaffoldContext: context,
            isPinSet: false,
            onLabelChange: (final _) {},
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: LongPrimaryButton(
                backgroundColor: const WidgetStatePropertyAll(Colors.red),
                icon: null,
                onPressed: viewModel.deleteWallet,
                text: L.delete,
              ),
            ),
            Expanded(
              child: LongPrimaryButton(
                icon: null,
                onPressed: () => viewModel.renameWallet(),
                text: L.rename,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
