import 'package:flutter/material.dart';

class CakeListTile extends StatelessWidget {
  const CakeListTile({
    super.key,
    required this.onTap,
    required this.text,
    this.trailing,
    this.icon,
    this.selected = false,
  });

  final String text;
  final Function(BuildContext context) onTap;
  final Widget? icon;
  final Widget? trailing;
  final bool selected;
  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Card(
      color: selected ? T.colorScheme.primary : T.colorScheme.surfaceContainer,
      child: ListTile(
        onTap: () => onTap(context),
        splashColor: T.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 12),
              if (icon != null) ...[
                SizedBox.square(dimension: 24, child: icon),
                SizedBox(width: 18),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 20,
                  color: selected ? T.colorScheme.onPrimary : T.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
