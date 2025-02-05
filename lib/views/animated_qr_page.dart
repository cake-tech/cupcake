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
            frames: viewModel.urqr,
          ),
        ),
        const SizedBox(height: 32),
        ..._extraButtons(),
      ],
    );
  }

  List<Widget> _extraButtons() {
    final List<Widget> toRet = [];
    for (var key in viewModel.alternativeCodes) {
      toRet.add(_urqrSwitchButton(key, viewModel.urqrList[key]!));
    }
    return toRet;
  }

  Widget _urqrSwitchButton(String key, List<String> value) {
    return OutlinedButton(
        onPressed: () {
          viewModel.urqr = value;
        },
        child: Text(key),);
  }
}
