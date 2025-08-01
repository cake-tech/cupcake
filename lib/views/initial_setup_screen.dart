import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/initial_setup_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';

class InitialSetupScreen extends AbstractView {
  InitialSetupScreen({super.key});

  @override
  InitialSetupViewModel viewModel = InitialSetupViewModel();

  @override
  Widget? body(final BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.maxFinite,
          child: Assets.icons.nightLanding.svg(fit: BoxFit.fitWidth),
        ),
        Text(
          L.welcome,
          style: T.textTheme.displayLarge?.copyWith(
            color: T.colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 72,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              L.to,
              style: T.textTheme.displaySmall?.copyWith(
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Assets.icons.cupcakeSmallIcon.svg(width: 36),
            SizedBox(width: 8),
            Text(
              "Cupcake",
              style: T.textTheme.displaySmall?.copyWith(
                fontSize: 26,
              ),
            ),
          ],
        ),
        const SizedBox(height: 42),
        Text(
          L.cupcake_slogan,
          style: TextStyle(fontSize: 16, color: T.colorScheme.onSurfaceVariant),
        ),
        const Spacer(),
        GestureDetector(
          onTap: viewModel.showTos,
          child: Text.rich(markdownText(L.tos_notice)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget? bottomNavigationBar(final BuildContext context) {
    return LongPrimaryButton(
      text: L.continue_,
      onPressed: () => CreateWallet(
        viewModel: CreateWalletViewModel(createMethod: null, needsPasswordConfirm: true),
      ).push(context),
    );
  }
}
