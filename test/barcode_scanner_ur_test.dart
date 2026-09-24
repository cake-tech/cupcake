import 'package:cupcake/utils/collect_ur_codes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('collectUrCodes appends later new ur parts after a duplicate', () {
    final existing = [
      'ur:bytes/1-3/aaa',
      'ur:bytes/2-3/bbb',
    ];
    final rawValues = [
      'ur:bytes/1-3/aaa',
      'ur:bytes/3-3/ccc',
    ];

    final result = collectUrCodes(existing, rawValues);

    expect(result, hasLength(3));
    expect(result, contains('ur:bytes/3-3/ccc'));
  });

  test('collectUrCodes ignores non-ur values', () {
    final result = collectUrCodes(
      ['ur:bytes/1-2/aaa'],
      ['not-ur', 'ur:bytes/2-2/bbb'],
    );

    expect(result, ['ur:bytes/1-2/aaa', 'ur:bytes/2-2/bbb']);
  });

  test('collectUrCodes does not duplicate when capture is only a duplicate', () {
    final existing = ['ur:bytes/1-2/aaa'];
    final result = collectUrCodes(existing, ['ur:bytes/1-2/aaa']);

    expect(result, ['ur:bytes/1-2/aaa']);
  });
}
