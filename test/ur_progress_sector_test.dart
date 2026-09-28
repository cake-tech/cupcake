import 'package:cupcake/utils/urqr.dart';
import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first ur part lights the first sector', () {
    final progress = URQrProgress.fromURQRData(
      URQRData.parse(['ur:bytes/1-3/aaa']),
    );

    expect(urSectorReceived(progress.receivedPartIndexes, 0), isTrue);
    expect(urSectorReceived(progress.receivedPartIndexes, 1), isFalse);
  });

  test('last ur part lights the last sector', () {
    final progress = URQrProgress.fromURQRData(
      URQRData.parse(['ur:bytes/3-3/ccc']),
    );

    expect(urSectorReceived(progress.receivedPartIndexes, 2), isTrue);
    expect(urSectorReceived(progress.receivedPartIndexes, 0), isFalse);
  });
}
