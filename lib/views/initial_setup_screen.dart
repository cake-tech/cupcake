import 'package:cup_cake/themes/base_theme.dart';
import 'package:cup_cake/view_model/create_wallet_view_model.dart';
import 'package:cup_cake/view_model/initial_setup_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/create_wallet.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cup_cake/const/resource.dart';

// ignore: must_be_immutable
class InitialSetupScreen extends AbstractView {
  @override
  InitialSetupViewModel viewModel = InitialSetupViewModel();

  InitialSetupScreen({super.key});
  @override
  Widget? body(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 16),
          child: Lottie.asset(
            R.ASSETS_CAKE_LANDING_JSON,
            repeat: true,
            onWarning: print,
          ),
        ),
        const Text("Welcome to"),
        const SizedBox(height: 8),
        Text(
          "Cupcake",
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        const Text("Keep you crypto even safer"),
        const Spacer(),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "Please make selection below to create or recover your wallet.",
            textAlign: TextAlign.center,
          ),
        ),
        LongSecondaryButton(
          text: "Create new wallet",
          icon: Icons.add,
          onPressed: () => CreateWallet.staticPush(
            context,
            CreateWalletViewModel(createMethod: CreateMethod.create),
          ),
        ),
        LongPrimaryButton(
          text: "Restore wallet",
          icon: Icons.restore,
          onPressed: () => CreateWallet.staticPush(
            context,
            CreateWalletViewModel(createMethod: CreateMethod.restore),
          ),
        ),
      ],
    );
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