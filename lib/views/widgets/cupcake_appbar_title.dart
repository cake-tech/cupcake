import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CupcakeAppbarTitle extends StatelessWidget {
  const CupcakeAppbarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/icons/icon-white.svg",
              height: 32, width: 32, color: Colors.white),
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
