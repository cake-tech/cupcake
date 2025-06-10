import 'package:flutter/material.dart';

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

  final EdgeInsets padding;
  final WidgetStateProperty<Color>? backgroundColor;
  final Color textColor;

  final String text;
  final Widget? textWidget;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double? width;
  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: 52,
        width: width,
        child: ElevatedButton.icon(
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                backgroundColor: backgroundColor,
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
