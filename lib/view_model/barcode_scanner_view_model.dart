import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:mobx/mobx.dart';

part 'barcode_scanner_view_model.g.dart';

class BarcodeScannerViewModel = BarcodeScannerViewModelBase with _$BarcodeScannerViewModel;

abstract class BarcodeScannerViewModelBase with ViewModel, Store {
  BarcodeScannerViewModelBase({required this.wallet});
  @override
  String get screenName => L.scan;

  @observable
  Barcode? barcode;

  @observable
  bool popped = false;

  @observable
  List<String> urCodes = [];

  URQRData get ur => URQRData.parse(urCodes);

  final CoinWallet wallet;

  final MobileScannerController mobileScannerCtrl = MobileScannerController();

  URQrProgress get urQrProgress => URQrProgress(
        expectedPartCount: ur.count - 1,
        processedPartsCount: ur.inputs.length,
        receivedPartIndexes: urParts(),
        percentage: ur.progress,
      );

  Future<void> handleUR() async {
    await callThrowable(
      () async {
        await wallet.handleUR(c!, ur);
      },
      L.error_handling_urqr_scan,
    );
  }

  Future<void> handleBarcode(final BarcodeCapture barcodes) async {
    for (final barcode in barcodes.barcodes) {
      if (barcode.rawValue!.startsWith("ur:")) {
        if (ur.progress == 1 && !popped) {
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
