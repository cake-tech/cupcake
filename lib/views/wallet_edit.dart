import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/utils/call_throwable.dart';
import 'package:cup_cake/view_model/wallet_edit_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/initial_setup_screen.dart';
import 'package:cup_cake/widgets/form_builder.dart';
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
                backgroundColor: const MaterialStatePropertyAll(Colors.red),
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
