import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/view_model/connect_wallet_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/wallet_home.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ConnectWallet extends AbstractView {
  ConnectWallet({
    required final CoinWallet wallet,
    required final bool canSkip,
    final bool isShowingInfo = true,
    super.key,
  }) : viewModel =
            ConnectWalletViewModel(wallet: wallet, canSkip: canSkip, isShowingInfo: isShowingInfo);

  @override
  final ConnectWalletViewModel viewModel;

  @override
  Widget body(final BuildContext context) {
    return Observer(
      builder: (final context) => SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 64),
            if (viewModel.isShowingInfo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64),
                child: viewModel.canSkip
                    ? Assets.icons.linkCakewallet.image()
                    : Assets.icons.linkCakewalletAlt.image(),
              ),
            if (!viewModel.isShowingInfo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Material(
                  color: Colors.white,
                  child: QrImageView(
                    data: viewModel.syncQRCode.first,
                    dataModuleStyle: QrDataModuleStyle(
                      color: Colors.black,
                      dataModuleShape: QrDataModuleShape.square,
                    ),
                    embeddedImage: AssetImage(Assets.icons.cupcakeQr.path),
                    embeddedImageEmitsError: true,
                    eyeStyle: QrEyeStyle(
                      color: Colors.black,
                      eyeShape: QrEyeShape.square,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text.rich(
                    markdownText(
                      viewModel.isShowingInfo
                          ? L.cake_restore_tutorial_1
                          : L.cake_restore_tutorial_2,
                    ),
                    textAlign: TextAlign.center,
                    style: T.textTheme.bodyLarge?.copyWith(
                      color: T.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return Observer(
      builder: (final context) => Column(
        children: [
          if (viewModel.canSkip)
            LongSecondaryButton(
              T,
              onPressed: () => WalletHome(coinWallet: viewModel.wallet).pushReplacement(context),
              text: L.skip,
            ),
          LongPrimaryButton(
            text: viewModel.isShowingInfo ? L.link_to_cakewallet : L.done,
            onPressed: () {
              if (!viewModel.isShowingInfo) {
                WalletHome(coinWallet: viewModel.wallet).pushReplacement(context);
              } else {
                viewModel.canSkip = false;
                viewModel.setIsShowingInfo(false);
              }
            },
          ),
        ],
      ),
    );
  }
}
