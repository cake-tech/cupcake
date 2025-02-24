import 'dart:async';

import 'package:cupcake/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class URQR extends StatefulWidget {
  URQR({
    super.key,
    required this.frames,
  });

  List<String> frames;

  @override
  // ignore: library_private_types_in_public_api
  _URQRState createState() => _URQRState();
}

class _URQRState extends State<URQR> {
  Timer? t;
  int frame = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      t = Timer.periodic(
        Duration(milliseconds: CupcakeConfig.instance.msForQrCode),
        (final timer) {
          _nextFrame();
        },
      );
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
  Widget build(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(17.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: Colors.white,
            ),
            child: QrImageView(
              dataModuleStyle: QrDataModuleStyle(
                color: Colors.black,
                dataModuleShape: QrDataModuleShape.square,
              ),
              eyeStyle: QrEyeStyle(
                color: Colors.black,
                eyeShape: QrEyeShape.square,
              ),
              data: widget.frames[frame % widget.frames.length],
              version: -1,
              size: 275,
            ),
          ),
        ),
      ],
    );
  }
}
