import 'package:flutter/material.dart';
import 'package:cupcake/gen/assets.gen.dart';

class CupcakeAppbarTitle extends StatelessWidget {
  const CupcakeAppbarTitle({super.key});

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.iconWhite.svg(
            width: 32,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          const SizedBox(
            width: 12,
          ),
          const Text(
            "Cupcake",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
