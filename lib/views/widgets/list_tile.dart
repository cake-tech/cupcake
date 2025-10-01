import 'package:flutter/material.dart';

class CakeListTile extends StatefulWidget {
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
  State<CakeListTile> createState() => _CakeListTileState();
}

class _CakeListTileState extends State<CakeListTile> {
  bool isProcessing = false;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Card(
      color: widget.selected ? T.colorScheme.primary : T.colorScheme.surfaceContainer,
      child: ListTile(
        onTap: isProcessing
            ? null
            : () {
                setState(() {
                  isProcessing = true;
                });
                try {
                  widget.onTap(context);
                } finally {
                  setState(() {
                    isProcessing = false;
                  });
                }
              },
        splashColor: T.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 12),
              if (widget.icon != null) ...[
                SizedBox.square(dimension: 24, child: widget.icon),
                SizedBox(width: 18),
              ],
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 20,
                  color: widget.selected ? T.colorScheme.onPrimary : T.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
