import 'dart:async';

import 'package:cup_cake/view_model/urqr_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

//ignore: must_be_immutable
class AnimatedURPage extends AbstractView {
  AnimatedURPage({super.key, required this.viewModel});

  @override
  final URQRViewModel viewModel;

  @override
  Widget body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64.0),
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

class URQR extends StatefulWidget {
  URQR({super.key, required this.frames});

  List<String> frames;

  @override
  // ignore: library_private_types_in_public_api
  _URQRState createState() => _URQRState();
}

const urFrameTime = 1000 ~/ 5;

class _URQRState extends State<URQR> {
  Timer? t;
  int frame = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      t = Timer.periodic(const Duration(milliseconds: urFrameTime), (timer) {
        _nextFrame();
      });
    });
  }

  void _nextFrame() {
    setState(() {
      frame++;
    });
  }

  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: QrImageView(
            data: widget.frames[frame % widget.frames.length],
            version: -1,
            size: 400,
          ),
        ),
      ],
    );
  }
}
