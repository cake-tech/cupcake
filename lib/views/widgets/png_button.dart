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
  final VoidCallback onPressed;
  @override
  State<PngButton> createState() => _FancyButtonThatWeDontCodeSoWeDoPNGInsteadOhNoWhatState();
}

class _FancyButtonThatWeDontCodeSoWeDoPNGInsteadOhNoWhatState extends State<PngButton> {
  bool isPressed = false;
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
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
      onTap: () {
        setState(() {
          isPressed = false;
        });
        widget.onPressed();
      },
      child: SizedBox(
        width: 95,
        height: 95,
        child: isPressed ? widget.pressedPngAsset : widget.pngAsset,
      ),
    );
  }
}
