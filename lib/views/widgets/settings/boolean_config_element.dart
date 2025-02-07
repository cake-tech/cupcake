import 'package:flutter/material.dart';

class BooleanConfigElement extends StatelessWidget {
  const BooleanConfigElement({
    super.key,
    required this.title,
    required this.subtitleEnabled,
    required this.subtitleDisabled,
    required this.value,
    required this.onChange,
  });

  final String title;
  final String subtitleEnabled;
  final String subtitleDisabled;
  final bool value;
  final Function(bool val) onChange;
  @override
  Widget build(final BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      subtitle: Text(value ? subtitleEnabled : subtitleDisabled),
      value: value,
      onChanged: (final bool? value) {
        onChange(value == true);
      },
    );
  }
}
