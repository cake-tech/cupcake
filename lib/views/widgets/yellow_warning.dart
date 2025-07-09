import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:flutter/material.dart';

class YellowWarning extends StatelessWidget {
  const YellowWarning({
    super.key,
    required this.text,
    this.padding = const EdgeInsets.only(left: 14, right: 14, bottom: 8, top: 16),
  });

  final String text;
  final EdgeInsets padding;
  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFB8860B),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Assets.icons.warning.svg(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    markdownText(text),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
