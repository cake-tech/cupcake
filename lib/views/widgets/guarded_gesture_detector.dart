import 'dart:async';

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

  final FutureOr<void> Function()? onTap;
  final FutureOr<void> Function()? onLongPress;
  final Widget child;
  final FutureOr<void> Function(DragUpdateDetails)? onPanUpdate;
  final FutureOr<void> Function(DragEndDetails)? onPanEnd;
  final FutureOr<void> Function(TapDownDetails)? onTapDown;
  final FutureOr<void> Function()? onTapCancel;

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
