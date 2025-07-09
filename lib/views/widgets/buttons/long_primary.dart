import 'package:flutter/material.dart';

class LongPrimaryButton extends StatelessWidget {
  const LongPrimaryButton({
    super.key,
    this.padding = const EdgeInsets.only(left: 24, right: 24, bottom: 8),
    final WidgetStateProperty<Color>? backgroundColorOverride,
    this.textColor,
    this.text = "",
    this.textWidget,
    this.icon,
    required this.onPressed,
    this.width = double.maxFinite,
  }) : backgroundColor = backgroundColorOverride;

  final EdgeInsets padding;
  final WidgetStateProperty<Color>? backgroundColor;
  final Color? textColor;

  final String text;
  final Widget? textWidget;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 50,
        width: width,
        child: ElevatedButton.icon(
          style: T.elevatedButtonTheme.style?.copyWith(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: backgroundColor ?? WidgetStateProperty.all(T.colorScheme.primary),
            elevation: const WidgetStatePropertyAll(0),
            side: const WidgetStatePropertyAll(
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
                  style: TextStyle(
                    color: textColor ?? T.colorScheme.onPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
          icon: icon == null
              ? Container()
              : Icon(
                  icon,
                  color: textColor ?? T.colorScheme.onPrimary,
                ),
        ),
      ),
    );
  }
}
