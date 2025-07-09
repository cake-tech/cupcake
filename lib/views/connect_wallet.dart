import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/view_model/connect_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/urqr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class ConnectWallet extends AbstractView {
  ConnectWallet({required final CoinWallet wallet, super.key})
      : viewModel = ConnectWalletViewModel(wallet: wallet);

  @override
  final ConnectWalletViewModel viewModel;

  @override
  Widget body(final BuildContext context) {
    return Observer(
      builder: (final context) => Column(
        children: [
          const SizedBox(height: 64),
          if (viewModel.isShowingInfo)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 64),
              child: Assets.icons.linkCakewallet.image(),
            ),
          if (!viewModel.isShowingInfo) URQR(frames: viewModel.syncQRCode),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text.rich(
                  markdownText(
                    viewModel.isShowingInfo ? L.cake_restore_tutorial_1 : L.cake_restore_tutorial_2,
                  ),
                  textAlign: TextAlign.center,
                  style: T.textTheme.bodyLarge?.copyWith(
                    color: T.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Observer(
      builder: (final context) => LongPrimaryButton(
        text: viewModel.isShowingInfo ? L.show_qr_code : L.done,
        onPressed: () {
          if (!viewModel.isShowingInfo) {
            Navigator.pop(context);
          } else {
            viewModel.isShowingInfo = false;
          }
        },
      ),
    );
  }
}
