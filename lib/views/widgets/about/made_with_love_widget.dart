import 'package:cupcake/gen/assets.gen.dart';
import 'package:cupcake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MadeWithLoveWidget extends StatelessWidget {
  const MadeWithLoveWidget({super.key});

  @override
  Widget build(final BuildContext context) {
    final L = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${L.made_with_love_by("❤️")} ",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        Assets.icons.tinyCakeLabs.svg(),
        Text(
          " ${L.cake_labs}",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
