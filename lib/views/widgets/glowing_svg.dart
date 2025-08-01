import 'dart:ui';

import 'package:cupcake/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GlowingSvg extends StatelessWidget {
  const GlowingSvg({super.key, required this.svg});

  final SvgGenImage svg;

  @override
  Widget build(final BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Opacity(
            opacity: 0.5,
            child: SvgPicture.asset(
              svg.path,
            ),
          ),
        ),
        SvgPicture.asset(
          svg.path,
        ),
      ],
    );
  }
}
