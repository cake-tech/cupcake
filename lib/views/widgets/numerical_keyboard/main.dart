import 'package:cupcake/views/widgets/numerical_keyboard/keyboard.dart';
import 'package:cupcake/views/widgets/numerical_keyboard/single_key.dart';
import 'package:flutter/cupertino.dart';

class NumericalKeyboard extends StatelessWidget {
  const NumericalKeyboard(
      {super.key,
      required this.ctrl,
      required this.rebuild,
      required this.showConfirm,
      required this.nextPage,
      required this.showComma});
  final TextEditingController ctrl;
  final VoidCallback rebuild;
  final bool Function() showConfirm;
  final VoidCallback? nextPage;
  final bool showComma;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a1, ctrl, rebuild),
          SingleKey(Keys.a2, ctrl, rebuild),
          SingleKey(Keys.a3, ctrl, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a4, ctrl, rebuild),
          SingleKey(Keys.a5, ctrl, rebuild),
          SingleKey(Keys.a6, ctrl, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.a7, ctrl, rebuild),
          SingleKey(Keys.a8, ctrl, rebuild),
          SingleKey(Keys.a9, ctrl, rebuild),
          const Spacer(),
        ]),
        Row(children: [
          const Spacer(),
          SingleKey(Keys.backspace, ctrl, rebuild),
          SingleKey(Keys.a0, ctrl, rebuild),
          if (showConfirm() &&
              (!showComma || ctrl.text.contains(getKeysChar(Keys.dot))))
            SingleKey(Keys.next, ctrl, nextPage),
          if (showComma && !ctrl.text.contains(getKeysChar(Keys.dot)))
            SingleKey(Keys.dot, ctrl, rebuild),
          Spacer(flex: showConfirm() || showComma ? 1 : 3),
        ]),
      ],
    );
  }
}
