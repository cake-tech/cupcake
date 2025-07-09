import 'package:flutter/material.dart';

/// Minimal markdown parser that supports:
/// - **bold**
/// - *italic*
/// - ~~strikethrough~~
TextSpan markdownText(final String input) {
  final List<InlineSpan> spans = [];
  final regex = RegExp(r'(\*\*.*?\*\*|\*.*?\*|~~.*?~~)');
  final matches = regex.allMatches(input);

  int lastEnd = 0;

  for (final match in matches) {
    if (match.start > lastEnd) {
      spans.add(TextSpan(text: input.substring(lastEnd, match.start)));
    }

    final String matchText = match.group(0)!;
    if (matchText.startsWith('**')) {
      spans.add(
        TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (matchText.startsWith('*')) {
      spans.add(
        TextSpan(
          text: matchText.substring(1, matchText.length - 1),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    } else if (matchText.startsWith('~~')) {
      spans.add(
        TextSpan(
          text: matchText.substring(2, matchText.length - 2),
          style: const TextStyle(decoration: TextDecoration.lineThrough),
        ),
      );
    }

    lastEnd = match.end;
  }

  if (lastEnd < input.length) {
    spans.add(TextSpan(text: input.substring(lastEnd)));
  }

  return TextSpan(children: spans);
}
