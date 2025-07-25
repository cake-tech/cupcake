import 'package:flutter/material.dart';

class SeedPhraseGridWidget extends StatelessWidget {
  const SeedPhraseGridWidget({
    super.key,
    required this.list,
    this.onSelect,
    this.numbers = true,
  });

  final List<String> list;
  final Function(String word, int index)? onSelect;
  final bool numbers;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length + (list.length % 3 == 1 ? 1 : 0),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 3.3,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemBuilder: (final BuildContext context, int index) {
        if (index == list.length - 1 && list.length % 3 == 1) {
          return const SizedBox();
        }
        if (index == list.length && list.length % 3 == 1) {
          index--;
        }
        final item = list[index];
        final numberCount = index + 1;
        return GestureDetector(
          onTap: () => onSelect?.call(item, index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: T.colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (numbers) ...[
                  SizedBox(
                    child: Text(
                      numberCount.toString(),
                      textAlign: TextAlign.center,
                      style: T.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: T.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    maxLines: 1,
                    textAlign: numbers ? null : TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    '${item[0].toLowerCase()}${item.substring(1)}',
                    style: T.textTheme.bodyMedium?.copyWith(
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: T.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
