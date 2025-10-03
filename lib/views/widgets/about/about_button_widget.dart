import 'package:flutter/material.dart';

class AboutButtonWidget extends StatelessWidget {
  const AboutButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFirst = false,
    this.isLast = false,
  });
  final String text;
  final VoidCallback onPressed;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  color: T.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: T.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
