import 'package:cupcake/themes/base_theme.dart';
import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';

class LongSecondaryButton extends LongPrimaryButton {
  const LongSecondaryButton({
    super.key,
    required super.text,
    required super.icon,
    required super.onPressed,
  });

  @override
  WidgetStateProperty<Color>? get backgroundColor => const WidgetStatePropertyAll(Colors.white);

  @override
  Color get textColor => BaseTheme.onBackgroundColor;
}
