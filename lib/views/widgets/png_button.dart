import 'package:cupcake/views/widgets/guarded_gesture_detector.dart';
import 'package:flutter/material.dart';

class PngButton extends StatefulWidget {
  const PngButton({
    super.key,
    required this.pngAsset,
    required this.pressedPngAsset,
    required this.onPressed,
  });
  final Widget pngAsset;
  final Widget pressedPngAsset;
  final Future<void> Function() onPressed;
  @override
  State<PngButton> createState() => _FancyButtonThatWeDontCodeSoWeDoPNGInsteadOhNoWhatState();
}

class _FancyButtonThatWeDontCodeSoWeDoPNGInsteadOhNoWhatState extends State<PngButton> {
  bool isPressed = false;
  @override
  Widget build(final BuildContext context) {
    return GuardedGestureDetector(
      onTapDown: (final details) {
        setState(() {
          isPressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          isPressed = false;
        });
      },
      onTap: () async {
        setState(() {
          isPressed = false;
        });
        await widget.onPressed();
      },
      child: SizedBox(
        width: 95,
        height: 95,
        child: isPressed ? widget.pressedPngAsset : widget.pngAsset,
      ),
    );
  }
}
