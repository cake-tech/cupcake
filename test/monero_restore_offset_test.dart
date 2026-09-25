import 'package:cupcake/coins/monero/seed_offset_check.dart';
import 'package:cupcake/utils/types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monero restore rejects a seed offset that does not match confirm', () {
    final blocks = seedOffsetMismatchBlocksCreate(
      method: CreateMethod.restore,
      restoringFromSeed: true,
      offset: 'alpha',
      confirm: 'beta',
    );

    expect(blocks, isTrue);
  });

  test('matching offsets and key restore are left alone', () {
    expect(
      seedOffsetMismatchBlocksCreate(
        method: CreateMethod.restore,
        restoringFromSeed: true,
        offset: 'alpha',
        confirm: 'alpha',
      ),
      isFalse,
    );
    expect(
      seedOffsetMismatchBlocksCreate(
        method: CreateMethod.restore,
        restoringFromSeed: false,
        offset: 'alpha',
        confirm: 'beta',
      ),
      isFalse,
    );
    expect(
      seedOffsetMismatchBlocksCreate(
        method: CreateMethod.create,
        restoringFromSeed: false,
        offset: 'alpha',
        confirm: 'beta',
      ),
      isTrue,
    );
  });
}
