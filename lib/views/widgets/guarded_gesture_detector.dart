import 'package:flutter/cupertino.dart';

class GuardedGestureDetector extends StatefulWidget {
  const GuardedGestureDetector({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.child,
    this.onPanUpdate,
    this.onPanEnd,
    this.onTapDown,
    this.onTapCancel,
  });

  final Future<void> Function()? onTap;
  final Future<void> Function()? onLongPress;
  final Widget child;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;
  final Function(TapDownDetails)? onTapDown;
  final Function()? onTapCancel;

  @override
  State<GuardedGestureDetector> createState() => _GuardedGestureDetectorState();
}

class _GuardedGestureDetectorState extends State<GuardedGestureDetector> {
  bool isProcessing = false;
  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTapDown,
      onTapCancel: widget.onTapCancel,
      onPanUpdate: widget.onPanUpdate,
      onPanEnd: widget.onPanEnd,
      onLongPress: widget.onLongPress == null
          ? null
          : () async {
              if (isProcessing) return;
              setState(() {
                isProcessing = true;
              });
              try {
                await widget.onLongPress?.call();
              } finally {
                setState(() {
                  isProcessing = false;
                });
              }
            },
      onTap: widget.onTap == null
          ? null
          : () async {
              if (isProcessing) return;
              setState(() {
                isProcessing = true;
              });
              try {
                await widget.onTap?.call();
              } finally {
                try {
                  setState(() {
                    isProcessing = false;
                  });
                } catch (e) {
                  print("error setting state: $e");
                }
              }
            },
      child: widget.child,
    );
  }
}
