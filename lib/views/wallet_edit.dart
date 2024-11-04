import 'package:cupcake/coins/abstract.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/view_model/wallet_edit_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/initial_setup_screen.dart';
import 'package:cupcake/widgets/form_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletEdit extends AbstractView {
  WalletEdit({super.key, required this.viewModel});
  static Future<void> staticPush(
      BuildContext context, CoinWalletInfo walletInfo) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) =>
            WalletEdit(viewModel: WalletEditViewModel(walletInfo: walletInfo)),
      ),
    );
  }

  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        FormBuilder(
          formElements: viewModel.form,
          scaffoldContext: context,
          isPinSet: false,
          showExtra: true,
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: LongPrimaryButton(
                backgroundColor: const WidgetStatePropertyAll(Colors.red),
                icon: null,
                onPressed: () {
                  callThrowable(
                    context,
                    () => viewModel.deleteWallet(context),
                    "Deleting wallet",
                  );
                },
                text: "Delete",
              ),
            ),
            Expanded(
              child: LongPrimaryButton(
                icon: null,
                onPressed: () {
                  callThrowable(context, () => viewModel.renameWallet(context),
                      "Rename wallet");
                },
                text: "Rename",
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  WalletEditViewModel viewModel;
}
