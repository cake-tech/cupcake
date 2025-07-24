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
  final String? subtitleEnabled;
  final String? subtitleDisabled;
  final bool value;
  final Function(bool val) onChange;
  String? get elementText => value ? subtitleEnabled : subtitleDisabled;
  @override
  Widget build(final BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: elementText != null ? Text(elementText!) : null,
      value: value,
      onChanged: (final bool? value) {
        onChange(value == true);
      },
    );
  }
}
