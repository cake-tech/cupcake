import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/view_model/barcode_scanner_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/barcode_scanner/progress_painter.dart';
import 'package:cupcake/views/widgets/barcode_scanner/switch_camera.dart';
import 'package:cupcake/views/widgets/barcode_scanner/toggle_flashlight_button.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/material.dart';

class BarcodeScanner extends AbstractView {
  BarcodeScanner({super.key, required final CoinWallet wallet})
      : viewModel = BarcodeScannerViewModel(wallet: wallet);

  @override
  final BarcodeScannerViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    viewModel.register(context);
    return Stack(
      children: [
        MobileScanner(
          onDetect: (final BarcodeCapture bc) =>
              viewModel.handleBarcode(context, bc),
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
