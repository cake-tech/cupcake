import 'package:cupcake/views/widgets/buttons/long_primary.dart';
import 'package:flutter/material.dart';

class LongSecondaryButton extends LongPrimaryButton {
  const LongSecondaryButton(
    this.T, {
    super.key,
    required super.text,
    super.icon,
    required super.onPressed,
  });

  final ThemeData T;

  @override
  WidgetStateProperty<Color>? get backgroundColor =>
      WidgetStatePropertyAll(T.colorScheme.surfaceContainer);

  @override
  Color get textColor => T.colorScheme.onSecondaryContainer;
}
