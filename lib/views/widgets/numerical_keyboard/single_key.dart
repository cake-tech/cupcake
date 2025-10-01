import 'package:cupcake/views/widgets/guarded_gesture_detector.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/keyboard.dart';
import 'package:flutter/material.dart';

class SingleKey extends StatelessWidget {
  const SingleKey(
    this.keyId,
    this.ctrl,
    this.callback, {
    super.key,
    this.longPress,
  });
  final Keys keyId;
  final TextEditingController ctrl;
  final Future<void> Function()? callback;
  final Future<void> Function()? longPress;
  @override
  Widget build(final BuildContext context) {
    final T = Theme.of(context);
    return Expanded(
      flex: 2,
      child: GuardedGestureDetector(
        onTap: () async {
          switch (keyId) {
            case Keys.backspace:
              if (ctrl.text.isNotEmpty) {
                ctrl.text = ctrl.text.substring(0, ctrl.text.length - 1);
              }
              break;
            case Keys.next:
              break;
            default:
              ctrl.text = "${ctrl.text}${getKeysChar(keyId)}";
          }
          await callback?.call();
        },
        onLongPress: longPress,
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 15),
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRect(
              child: Material(
                color: T.colorScheme.surfaceContainer,
                shape: CircleBorder(),
                child: Center(child: getKeyWidgetPinPad(keyId, T)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
