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
    final T = Theme.of(context);
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xff8E5800),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xffFFE69C), width: 2),
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
                          color: T.colorScheme.onSurface,
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
