import 'dart:typed_data';

import 'package:cupcake/utils/psbt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('psbt warns when the fee cannot be checked and the sighash is not ALL', () {
    final warnings = psbtConfirmationWarnings(_v2Psbt(sighash: 0x02));

    expect(warnings, isNotEmpty);
    expect(warnings.join('\n'), contains('cannot be independently verified'));
    expect(warnings.join('\n'), contains('SIGHASH_NONE'));
  });

  test('psbt with a previous transaction and no sighash override stays quiet', () {
    final warnings = psbtConfirmationWarnings(_v2Psbt(includePrevout: true));

    expect(warnings, isEmpty);
  });

  test('psbt that cannot be parsed warns instead of staying silent', () {
    final warnings = psbtConfirmationWarnings(Uint8List.fromList([0x00]));

    expect(warnings, isNotEmpty);
    expect(warnings.single, contains('Could not verify'));
  });
}

/// Minimal PSBT v2: one input, one output.
Uint8List _v2Psbt({final int? sighash, final bool includePrevout = false}) {
  final bytes = <int>[
    0x70, 0x73, 0x62, 0x74, 0xff,
    0x01, 0x04, 0x01, 0x01, // input count = 1
    0x01, 0x05, 0x01, 0x01, // output count = 1
    0x00,
  ];
  if (includePrevout) {
    bytes.addAll([0x01, 0x00, 0x01, 0x00]);
  }
  if (sighash != null) {
    bytes.addAll([0x01, 0x03, 0x04, sighash, 0x00, 0x00, 0x00]);
  }
  bytes.addAll([0x00, 0x00]);
  return Uint8List.fromList(bytes);
}
