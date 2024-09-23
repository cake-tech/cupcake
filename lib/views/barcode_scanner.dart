import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/barcode_scanner_view_model.dart';
import 'package:cup_cake/views/abstract.dart';
import 'package:cup_cake/views/widgets/barcode_scanner/progress_painter.dart';
import 'package:cup_cake/views/widgets/barcode_scanner/switch_camera.dart';
import 'package:cup_cake/views/widgets/barcode_scanner/toggle_flashlight_button.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//ignore: must_be_immutable
class BarcodeScanner extends AbstractView {
  BarcodeScanner({super.key, required CoinWallet wallet})
      : viewModel = BarcodeScannerViewModel(wallet: wallet);

  static Future<void> pushStatic(
      BuildContext context, CoinWallet wallet) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (BuildContext context) {
          return BarcodeScanner(wallet: wallet);
        },
      ),
    );
  }

  @override
  final BarcodeScannerViewModel viewModel;

  @override
  Widget? body(BuildContext context) {
    viewModel.register(context);
    return Stack(
      children: [
        MobileScanner(
          onDetect: (BarcodeCapture bc) => viewModel.handleBarcode(context, bc),
          controller: viewModel.mobileScannerCtrl,
        ),
        if (viewModel.ur.inputs.isNotEmpty)
          Center(
            child: Text("${viewModel.ur.inputs.length}/${viewModel.ur.count}",
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Colors.white)),
          ),
        SizedBox(
          child: Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: CustomPaint(
                painter: ProgressPainter(
                  urQrProgress: viewModel.urQrProgress,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  AppBar get appBar => AppBar(
        title: Text(viewModel.screenName),
        actions: [
          SwitchCameraButton(controller: viewModel.mobileScannerCtrl),
          ToggleFlashlightButton(controller: viewModel.mobileScannerCtrl),
        ],
      );
}
