import 'package:cupcake/coins/abstract/wallet.dart';
import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/view_model/abstract.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:mobx/mobx.dart';

part 'barcode_scanner_view_model.g.dart';

class BarcodeScannerViewModel = BarcodeScannerViewModelBase with _$BarcodeScannerViewModel;

abstract class BarcodeScannerViewModelBase extends ViewModel with Store {
  BarcodeScannerViewModelBase({required this.wallet});

  @override
  String get screenName => L.scan;

  @observable
  Barcode? barcode;

  @observable
  bool popped = false;

  @observable
  List<String> urCodes = [];

  final CoinWallet wallet;

  final MobileScannerController mobileScannerCtrl = MobileScannerController();

  Future<void> handleUR() async {
    await callThrowable(
      () async {
        await wallet.handleUR(c!, URQRData.parse(urCodes));
      },
      L.error_handling_urqr_scan,
    );
  }

  @action
  Future<void> handleBarcode(final BarcodeCapture barcodes) async {
    for (final barcode in barcodes.barcodes) {
      if (barcode.rawValue!.startsWith("ur:")) {
        if (URQRData.parse(urCodes).progress == 1 && !popped) {
          popped = true;
          await handleUR();
          return;
        }
        if (urCodes.contains(barcode.rawValue)) return;
        urCodes = [...urCodes, barcode.rawValue!];
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
    for (final inp in URQRData.parse(urCodes).inputs) {
      try {
        l.add(int.parse(inp.split("/")[1].split("-")[0]));
      } catch (e) {
        print(e);
      }
    }
    return l;
  }
}
