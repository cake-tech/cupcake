import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/barcode_scanner_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/barcode_scanner/progress_painter.dart';
import 'package:cupcake/views/widgets/barcode_scanner/switch_camera.dart';
import 'package:cupcake/views/widgets/barcode_scanner/toggle_flashlight_button.dart';
import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BarcodeScanner extends AbstractView {
  BarcodeScanner({
    super.key,
    required final CoinWallet wallet,
  }) : viewModel = BarcodeScannerViewModel(
          wallet: wallet,
        );

  @override
  final BarcodeScannerViewModel viewModel;

  @override
  Widget? body(final BuildContext context) {
    return Observer(
      builder: (final BuildContext context) {
        final ur = URQRData.parse(viewModel.urCodes);
        return Stack(
          children: [
            MobileScanner(
              onDetect: (final BarcodeCapture bc) => viewModel.handleBarcode(bc),
              controller: viewModel.mobileScannerCtrl,
            ),
            if (ur.inputs.isNotEmpty)
              Center(
                child: Text(
                  "${ur.inputs.length}/${ur.count}",
                  style: T.textTheme.displayLarge?.copyWith(color: Colors.white),
                ),
              ),
            SizedBox(
              child: Center(
                child: SizedBox(
                  width: 250,
                  height: 250,
                  child: CustomPaint(
                    painter: ProgressPainter(
                      urQrProgress: URQrProgress.fromURQRData(ur),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
