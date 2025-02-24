import 'package:cupcake/views/widgets/numerical_keyboard/keyboard.dart';
import 'package:flutter/material.dart';

class SingleKey extends StatelessWidget {
  const SingleKey(this.keyId, this.ctrl, this.callback,
      {super.key, this.longPress});
  final Keys keyId;
  final TextEditingController ctrl;
  final VoidCallback? callback;
  final VoidCallback? longPress;
  @override
  Widget build(final BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipRect(
          child: Material(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: InkWell(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              onTap: () {
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
                callback?.call();
              },
              onLongPress: longPress,
              child: Center(
                child: getKeyWidgetPinPad(keyId),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
