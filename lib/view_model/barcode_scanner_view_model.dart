import 'package:cup_cake/coins/abstract.dart';
import 'package:cup_cake/view_model/abstract.dart';
import 'package:cup_cake/views/widgets/barcode_scanner/progress_painter.dart';
import 'package:fast_scanner/fast_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

class BarcodeScannerViewModel extends ViewModel {
  BarcodeScannerViewModel({required this.wallet});
  @override
  String get screenName => "Scan";
  Barcode? barcode;
  bool popped = false;

  List<String> urCodes = [];
  late var ur = URQRToURQRData(urCodes);

  final CoinWallet wallet;

  final MobileScannerController mobileScannerCtrl = MobileScannerController();

  URQrProgress get urQrProgress => URQrProgress(
        expectedPartCount: ur.count - 1,
        processedPartsCount: ur.inputs.length,
        receivedPartIndexes: urParts(),
        percentage: ur.progress,
      );

  Future<void> handleUR(BuildContext context) async {
    if (ur.tag.startsWith("xmr-")) {
      if (wallet.coin.type != Coins.monero) {
        throw Exception(
            "${ur.tag} found, but currently opened wallet is not Monero");
      }
      wallet.handleUR(context, ur);
    }
  }

  void handleBarcode(BuildContext context, BarcodeCapture barcodes) {
    for (final barcode in barcodes.barcodes) {
      print(barcode.rawValue!);
      if (barcode.rawValue!.startsWith("ur:")) {
        if (urCodes.contains(barcode.rawValue)) return;
        urCodes.add(barcode.rawValue!);
        ur = URQRToURQRData(urCodes);
        markNeedsBuild();
        if (ur.progress == 1) {
          popped = true;
          markNeedsBuild();
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop(ur.inputs.join("\n"));
          });
          return;
        }
      }
    }
    if (urCodes.isNotEmpty) return;
    if (!context.mounted) return;
    barcode = barcodes.barcodes.firstOrNull;
    if (barcode != null && popped != true) {
      popped = true;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(barcode?.rawValue ?? "");
      });
    }
    markNeedsBuild();
  }

  List<int> urParts() {
    List<int> l = [];
    for (var inp in ur.inputs) {
      try {
        l.add(int.parse(inp.split("/")[1].split("-")[0]));
      } catch (e) {}
    }
    return l;
  }
}

class URQRData {
  URQRData(
      {required this.tag,
      required this.str,
      required this.progress,
      required this.count,
      required this.error,
      required this.inputs});
  final String tag;
  final String str;
  final double progress;
  final int count;
  final String error;
  final List<String> inputs;
  Map<String, dynamic> toJson() {
    return {
      "tag": tag,
      "str": str,
      "progress": progress,
      "count": count,
      "error": error,
      "inputs": inputs,
    };
  }
}

URQRData URQRToURQRData(List<String> urqr_) {
  final urqr = urqr_.toSet().toList();
  urqr.sort((s1, s2) {
    final s1s = s1.split("/");
    final s1frameStr = s1s[1].split("-");
    final s1curFrame = int.parse(s1frameStr[0]);
    final s2s = s2.split("/");
    final s2frameStr = s2s[1].split("-");
    final s2curFrame = int.parse(s2frameStr[0]);
    return s1curFrame - s2curFrame;
  });

  String tag = '';
  int count = 0;
  String bw = '';
  for (var elm in urqr) {
    final s = elm.substring(elm.indexOf(":") + 1); // strip down ur: prefix
    final s2 = s.split("/");
    tag = s2[0];
    final frameStr = s2[1].split("-");
    // final curFrame = int.parse(frameStr[0]);
    count = int.parse(frameStr[1]);
    final byteWords = s2[2];
    bw += byteWords;
  }
  String? error;

  return URQRData(
    tag: tag,
    str: bw,
    progress: count == 0 ? 0 : (urqr.length / count),
    count: count,
    error: error ?? "",
    inputs: urqr,
  );
}
