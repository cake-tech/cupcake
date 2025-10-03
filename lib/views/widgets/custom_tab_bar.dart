import 'package:cupcake/views/widgets/guarded_gesture_detector.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });
  final List<String> tabs;
  final int selectedIndex;
  final Function(int) onTabSelected;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);

    return SizedBox(
      height: 48,
      width: double.maxFinite,
      child: Row(
        children: tabs.asMap().entries.map((final entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 24 : 18),
            child: GuardedGestureDetector(
              onTap: () => onTabSelected(index),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? T.colorScheme.onSurface : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: T.textTheme.titleMedium!.copyWith(
                      color: isSelected
                          ? T.colorScheme.onSurface
                          : T.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 20,
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
