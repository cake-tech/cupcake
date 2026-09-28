import 'package:cupcake/utils/accept_ur_part.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('acceptUrPart completes on the frame that finishes the set', () {
    final first = acceptUrPart(const [], 'ur:bytes/1-2/aaa');
    expect(first.completed, isFalse);
    expect(first.codes, ['ur:bytes/1-2/aaa']);

    final second = acceptUrPart(first.codes, 'ur:bytes/2-2/bbb');
    expect(second.completed, isTrue);
    expect(second.codes, ['ur:bytes/1-2/aaa', 'ur:bytes/2-2/bbb']);
  });

  test('acceptUrPart completes a single-part ur on the first scan', () {
    final only = acceptUrPart(const [], 'ur:bytes/1-1/aaa');
    expect(only.completed, isTrue);
    expect(only.codes, ['ur:bytes/1-1/aaa']);
  });
}
