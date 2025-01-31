import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/call_throwable.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/cupertino.dart';

class BarcodeScannerViewModel extends ViewModel {
  BarcodeScannerViewModel({required this.wallet});
  @override
  String get screenName => L.scan;
  Barcode? barcode;
  bool popped = false;

  List<String> urCodes = [];
  late var ur = URQRData.parse(urCodes);

  final CoinWallet wallet;

  final MobileScannerController mobileScannerCtrl = MobileScannerController();

  URQrProgress get urQrProgress => URQrProgress(
        expectedPartCount: ur.count - 1,
        processedPartsCount: ur.inputs.length,
        receivedPartIndexes: urParts(),
        percentage: ur.progress,
      );

  Future<void> handleUR(BuildContext context) async {
    callThrowable(
      context,
      () => wallet.handleUR(context, ur),
      "Error handling URQR scan",
    );
  }

  void handleBarcode(BuildContext context, BarcodeCapture barcodes) async {
    for (final barcode in barcodes.barcodes) {
      if (barcode.rawValue!.startsWith("ur:")) {
        print("handleUR: ${ur.progress} : $popped");
        if (ur.progress == 1 && !popped) {
          print("handleUR called");
          popped = true;
          await handleUR(context);
          markNeedsBuild();
          return;
        }
        if (urCodes.contains(barcode.rawValue)) return;
        urCodes.add(barcode.rawValue!);
        ur = URQRData.parse(urCodes);

        markNeedsBuild();
      }
    }
    if (urCodes.isNotEmpty) return;
    if (!context.mounted) return;
    barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && popped != true) {
      popped = true;
      await handleUR(context);
    }
    markNeedsBuild();
  }

  List<int> urParts() {
    List<int> l = [];
    for (var inp in ur.inputs) {
      try {
        l.add(int.parse(inp.split("/")[1].split("-")[0]));
      } catch (e) {
        print(e);
      }
    }
    return l;
  }
}
