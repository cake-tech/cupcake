import 'package:cupcake/views/widgets/about/about_button_widget.dart';
import 'package:flutter/material.dart';

class AboutButtonGroupWidget extends StatelessWidget {
  const AboutButtonGroupWidget({
    super.key,
    required this.buttons,
  });
  final List<AboutButtonWidget> buttons;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: T.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: buttons.asMap().entries.map((final entry) {
          final index = entry.key;
          final button = entry.value;

          return Column(
            children: [
              button,
              if (index < buttons.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: T.colorScheme.surfaceContainerHighest,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
