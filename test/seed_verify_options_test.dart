import 'dart:math';

import 'package:cupcake/utils/seed_verify_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed check offers the correct word once and leaves the word list alone', () {
    final words = ['alpha', 'bravo', 'correct', 'delta', 'echo', 'foxtrot', 'golf'];
    final original = List<String>.from(words);

    final options = seedVerifyOptions(
      wordList: words,
      correctWord: 'correct',
      random: _KeepOrder(),
    );

    expect(words, original);
    expect(options.where((final word) => word == 'correct'), hasLength(1));
    expect(options.toSet(), hasLength(options.length));
  });

  test('seed check does not reorder the shared word list', () {
    final words = ['alpha', 'bravo', 'correct', 'delta', 'echo', 'foxtrot', 'golf'];
    final original = List<String>.from(words);

    seedVerifyOptions(
      wordList: words,
      correctWord: 'golf',
      random: _AlwaysZero(),
    );

    expect(words, original);
  });
}

class _AlwaysZero implements Random {
  @override
  int nextInt(final int max) => 0;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}

class _KeepOrder implements Random {
  @override
  int nextInt(final int max) => max - 1;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}
