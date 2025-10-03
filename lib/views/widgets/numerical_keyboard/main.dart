import 'package:cupcake/views/widgets/numerical_keyboard/keyboard.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/single_key.dart';
import 'package:flutter/cupertino.dart';

class NumericalKeyboard extends StatefulWidget {
  const NumericalKeyboard({
    super.key,
    required this.ctrl,
    required this.showConfirm,
    required this.nextPage,
    required this.onConfirmLongPress,
    required this.showComma,
  });
  final TextEditingController ctrl;
  final bool Function() showConfirm;
  final Future<void> Function()? nextPage;
  final Future<void> Function()? onConfirmLongPress;
  final bool showComma;

  @override
  State<NumericalKeyboard> createState() => _NumericalKeyboardState();
}

class _NumericalKeyboardState extends State<NumericalKeyboard> {
  Future<void> rebuild() async {
    setState(() {});
  }

  @override
  Widget build(final BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            SingleKey(Keys.a1, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a2, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a3, widget.ctrl, rebuild),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            SingleKey(Keys.a4, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a5, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a6, widget.ctrl, rebuild),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            SingleKey(Keys.a7, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a8, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.a9, widget.ctrl, rebuild),
            const Spacer(),
          ],
        ),
        Row(
          children: [
            const Spacer(),
            if (widget.showConfirm() &&
                (!widget.showComma || widget.ctrl.text.contains(getKeysChar(Keys.dot))))
              SingleKey(
                Keys.next,
                widget.ctrl,
                widget.nextPage,
                longPress: widget.onConfirmLongPress,
              )
            else
              const Spacer(flex: 2),
            SizedBox(width: 8),
            SingleKey(Keys.a0, widget.ctrl, rebuild),
            SizedBox(width: 8),
            SingleKey(Keys.backspace, widget.ctrl, rebuild),
            const Spacer(),
          ],
        ),
      ],
    );
  }
}
