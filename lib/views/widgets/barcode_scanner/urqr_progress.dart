import 'package:cupcake/utils/urqr.dart';

class URQrProgress {
  URQrProgress({
    required this.expectedPartCount,
    required this.processedPartsCount,
    required this.receivedPartIndexes,
    required this.percentage,
  });
  int expectedPartCount;
  int processedPartsCount;
  List<int> receivedPartIndexes;
  double percentage;

  bool equals(final URQrProgress? progress) {
    if (progress == null) {
      return false;
    }
    return processedPartsCount == progress.processedPartsCount;
  }

  static URQrProgress fromURQRData(final URQRData ur) {
    return URQrProgress(
      expectedPartCount: ur.count,
      processedPartsCount: ur.inputs.length,
      receivedPartIndexes: ur.inputs.map((final e) => int.tryParse(e.split("/")[1].split("-")[0]) ?? 0).toList(),
      percentage: ur.progress,
    );
  }
}
