import 'package:cupcake/utils/text_span_markdown.dart';
import 'package:cupcake/view_model/verify_seed_view_model.dart';
import 'package:cupcake/views/abstract.dart';
import 'package:cupcake/views/widgets/seed_grid.dart';
import 'package:flutter/material.dart';

class VerifySeedPage extends AbstractView {
  VerifySeedPage({
    super.key,
    required final List<String> seedWords,
    required final List<String> wordList,
  }) : viewModel = VerifySeedViewModel(
          seedWords: seedWords,
          wordList: wordList,
        );
  @override
  bool get hasBackground => true;

  @override
  bool get canPop => false;

  @override
  final VerifySeedViewModel viewModel;

  @override
  Widget body(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 82),
        Text.rich(
          markdownText("What is the **${viewModel.randomIndex + 1}** word of your seed phrase?"),
          style: T.textTheme.displaySmall?.copyWith(
            fontSize: 26,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: SeedPhraseGridWidget(
              list: viewModel.randomWords,
              onSelect: (final String word, final int index) {
                Navigator.of(context).pop(viewModel.result(word));
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
