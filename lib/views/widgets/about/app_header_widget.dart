import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class AppHeaderWidget extends StatelessWidget {
  const AppHeaderWidget({
    super.key,
    required this.appName,
    required this.fullVersion,
  });
  final String appName;
  final String fullVersion;

  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 136, // 120 (icon height) + 16 (half badge height)
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Center(
                  child: Assets.icons.cupcakeAbout.svg(
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              Positioned(
                bottom: 0, // Position at bottom of the SizedBox
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: T.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    fullVersion,
                    style: TextStyle(
                      color: T.colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          appName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: T.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
