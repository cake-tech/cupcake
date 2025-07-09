import 'package:flutter/material.dart';

class SeedPhraseGridWidget extends StatelessWidget {
  const SeedPhraseGridWidget({
    super.key,
    required this.list,
    this.onSelect,
  });

  final List<String> list;
  final Function(String word, int index)? onSelect;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return GridView.builder(
      itemCount: list.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.8,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemBuilder: (final BuildContext context, final index) {
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
                SizedBox(
                  child: Text(
                    numberCount.toString(),
                    textAlign: TextAlign.center,
                    style: T.textTheme.bodyLarge?.copyWith(
                      height: 1.9,
                      fontWeight: FontWeight.w700,
                      color: T.colorScheme.onSurface.withAlpha(128),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    '${item[0].toLowerCase()}${item.substring(1)}',
                    style: T.textTheme.bodyMedium?.copyWith(
                      height: 1.9,
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
