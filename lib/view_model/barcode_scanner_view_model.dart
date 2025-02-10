import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/dev/generate_rebuild.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:fast_scanner/fast_scanner.dart';

part 'barcode_scanner_view_model.g.dart';

@GenerateRebuild()
class BarcodeScannerViewModel extends ViewModel {
  BarcodeScannerViewModel({required this.wallet});
  @override
  String get screenName => L.scan;

  @RebuildOnChange()
  Barcode? $barcode;

  @RebuildOnChange()
  bool $popped = false;

  @RebuildOnChange()
  List<String> $urCodes = [];

  URQRData get ur => URQRData.parse(urCodes);

  final CoinWallet wallet;

  final MobileScannerController mobileScannerCtrl = MobileScannerController();

  URQrProgress get urQrProgress => URQrProgress(
        expectedPartCount: ur.count - 1,
        processedPartsCount: ur.inputs.length,
        receivedPartIndexes: urParts(),
        percentage: ur.progress,
      );

  @ThrowOnUI(message: "Error handling URQR scan")
  Future<void> $handleUR() async {
    await wallet.handleUR(c!, ur);
  }

  Future<void> handleBarcode(final BarcodeCapture barcodes) async {
    for (final barcode in barcodes.barcodes) {
      if (barcode.rawValue!.startsWith("ur:")) {
        print("handleUR: ${ur.progress} : $popped");
        if (ur.progress == 1 && !popped) {
          print("handleUR called");
          popped = true;
          await handleUR();
          return;
        }
        if (urCodes.contains(barcode.rawValue)) return;
        urCodes.add(barcode.rawValue!);
      }
    }
    if (urCodes.isNotEmpty) return;
    if (!mounted) return;
    barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && popped != true) {
      popped = true;
      await handleUR();
    }
  }

  List<int> urParts() {
    final List<int> l = [];
    for (final inp in ur.inputs) {
      try {
        l.add(int.parse(inp.split("/")[1].split("-")[0]));
      } catch (e) {
        print(e);
      }
    }
    return l;
  }
}
