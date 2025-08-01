import 'dart:math';

import 'package:cupcake/view_model/abstract.dart';
import 'package:mobx/mobx.dart';

part 'verify_seed_view_model.g.dart';

class VerifySeedViewModel = VerifySeedViewModelBase with _$VerifySeedViewModel;

abstract class VerifySeedViewModelBase extends ViewModel with Store {
  VerifySeedViewModelBase({
    required this.seedWords,
    required this.wordList,
  });

  @override
  String get screenName => L.pick_correct_word;

  @override
  bool get hasBackground => true;

  final List<String> seedWords;
  final List<String> wordList;

  late final randomIndex = Random().nextInt(seedWords.length);
  String get randomWord => seedWords[randomIndex];

  late final List<String> randomWords = () {
    final w = wordList;
    w.shuffle(Random.secure());
    final elms = w.take(5).toList();
    elms.add(randomWord);
    elms.toSet(); // in case we got a duplicate
    return elms.toList()..shuffle(Random.secure());
  }();

  bool result(final String guessedWord) {
    return guessedWord.toLowerCase() == randomWord.toLowerCase();
  }
}
