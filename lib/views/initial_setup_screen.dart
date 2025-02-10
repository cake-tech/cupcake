import 'package:cupcake/coins/types.dart';
import 'package:cupcake/view_model/initial_setup_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:cupcake/views/widgets/buttons/long_secondary.dart';
import 'package:flutter/material.dart';

class InitialSetupScreen extends AbstractView {
  InitialSetupScreen({super.key});

  @override
  InitialSetupViewModel viewModel = InitialSetupViewModel();

  @override
  Widget? body(final BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 64.0, vertical: 24),
              child: Assets.cakeLanding.lottie()),
          Text(L.welcome_to,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  )),
          const SizedBox(height: 8),
          Text(
            "Cupcake",
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            L.cupcake_slogan,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          const SizedBox(height: 8),
          LongSecondaryButton(
            text: L.create_new_wallet,
            icon: Icons.add,
            onPressed: () => CreateWallet(
              createMethod: CreateMethod.create,
              needsPasswordConfirm: true,
            ).push(context),
          ),
          LongPrimaryButton(
            text: L.restore_wallet,
            icon: Icons.restore,
            onPressed: () => CreateWallet(
              createMethod: CreateMethod.restore,
              needsPasswordConfirm: true,
            ).push(context),
          ),
        ],
      ),
    );
  }
}
