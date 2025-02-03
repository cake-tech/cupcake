import 'package:cupcake/view_model/urqr_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/urqr.dart';
import 'package:flutter/material.dart';

class AnimatedURPage extends AbstractView {
  AnimatedURPage({super.key, required Map<String, List<String>> urqrList})
      : viewModel = URQRViewModel(urqrList: urqrList);

  @override
  final URQRViewModel viewModel;

  @override
  Widget body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64.0, left: 32, right: 32),
          child: URQR(
            frames: viewModel.urqr..removeWhere((element) => element.isEmpty),
          ),
        ),
        const SizedBox(height: 32),
        ..._extraButtons(),
      ],
    );
  }

  List<Widget> _extraButtons() {
    final Map<String, List<String>> copiedList = {};
    copiedList.addAll(viewModel.urqrList);
    copiedList.removeWhere((key, value) =>
        value.join("\n").trim() == viewModel.urqr.join("\n").trim());
    final List<Widget> toRet = [];
    final keys = copiedList.keys;
    for (var key in keys) {
      toRet.add(_urqrSwitchButton(key, copiedList[key]!));
    }
    return toRet;
  }

  Widget _urqrSwitchButton(String key, List<String> value) {
    return OutlinedButton(
        onPressed: () {
          viewModel.urqr = value;
          viewModel.markNeedsBuild();
        },
        child: Text(key));
  }
}
