import 'dart:math';

/// Six choices for the seed check, including [correctWord] once.
///
/// Copies [wordList] before shuffling so the shared BIP39 list stays in order.
List<String> seedVerifyOptions({
  required final List<String> wordList,
  required final String correctWord,
  required final Random random,
}) {
  final pool = List<String>.from(wordList)..shuffle(random);
  final chosen = <String>[];
  for (final word in pool) {
    if (word.toLowerCase() == correctWord.toLowerCase()) continue;
    chosen.add(word);
    if (chosen.length == 5) break;
  }
  chosen.add(correctWord);
  chosen.shuffle(random);
  return chosen;
}
