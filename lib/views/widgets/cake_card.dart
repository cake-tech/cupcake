import 'package:flutter/material.dart';

class CakeCard extends StatelessWidget {
  const CakeCard(
      {super.key,
      required this.child,
      this.internalPadding = const EdgeInsets.only(
        top: 24.0,
        left: 24.0,
        bottom: 24,
        right: 24,
      ),
      this.externalPadding = const EdgeInsets.only(
        top: 4,
        left: 16.0,
        bottom: 4,
        right: 16,
      ),
      this.firmPadding =
          const EdgeInsets.only(top: 24.0, left: 24.0, bottom: 24, right: 24)});

  final Widget child;
  final EdgeInsets internalPadding;
  final EdgeInsets externalPadding;
  final EdgeInsets firmPadding;
  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: externalPadding,
      child: SizedBox(
        width: double.maxFinite,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Padding(
            padding: firmPadding,
            child: SizedBox(
              width: double.maxFinite,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
