import 'package:cupcake/themes/base_theme.dart';
import 'package:cupcake/view_model/create_wallet_view_model.dart';
import 'package:cupcake/view_model/initial_setup_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/create_wallet.dart';
import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InitialSetupScreen extends AbstractView {
  @override
  InitialSetupViewModel viewModel = InitialSetupViewModel();

  InitialSetupScreen({super.key});
  @override
  Widget? body(BuildContext context) {
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
            //style: Theme.of(context).textTheme.displaySmall,
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
              onPressed: () => CreateWallet.staticPush(
                context,
                CreateWalletViewModel(createMethod: CreateMethod.create),
              ),
            ),
            LongPrimaryButton(
              text: L.restore_wallet,
              icon: Icons.restore,
              onPressed: () => CreateWallet.staticPush(
                context,
                CreateWalletViewModel(createMethod: CreateMethod.restore),
              ),
            ),
          ],
        ));
  }
}

class LongSecondaryButton extends LongPrimaryButton {
  const LongSecondaryButton(
      {super.key,
      required super.text,
      required super.icon,
      required super.onPressed});

  @override
  MaterialStateProperty<Color>? get backgroundColor =>
      const MaterialStatePropertyAll(Colors.white);

  @override
  Color get textColor => onBackgroundColor;
}

class LongPrimaryButton extends StatelessWidget {
  const LongPrimaryButton({
    super.key,
    this.padding = const EdgeInsets.only(left: 24, right: 24, bottom: 8),
    this.backgroundColor,
    this.textColor = Colors.white,
    this.text = "",
    this.textWidget,
    required this.icon,
    required this.onPressed,
    this.width = double.maxFinite,
  });

  final padding;
  final MaterialStateProperty<Color>? backgroundColor;
  final Color textColor;

  final String text;
  final Widget? textWidget;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 52,
        width: width,
        child: ElevatedButton.icon(
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: backgroundColor,
                elevation: const MaterialStatePropertyAll(0),
                side: const MaterialStatePropertyAll(
                  BorderSide(
                    width: 0,
                    color: Colors.transparent,
                  ),
                ),
              ),
          onPressed: onPressed,
          label: textWidget != null
              ? textWidget!
              : Text(
                  text,
                  style: TextStyle(color: textColor),
                ),
          icon: icon == null
              ? Container()
              : Icon(
                  icon,
                  color: textColor,
                ),
        ),
      ),
    );
  }
}
