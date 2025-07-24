import 'package:flutter/material.dart';

/// Minimal markdown parser that supports:
/// - **bold**
/// - *italic*
/// - ~~strikethrough~~
/// - __underline__
/// - Any combination of the above (e.g., **__bold underline__**, ~~*italic strikethrough*~~)
TextSpan markdownText(final String input) {
  final List<InlineSpan> spans = [];
  final StringBuffer currentText = StringBuffer();

  // Track active formatting states
  bool isBold = false;
  bool isItalic = false;
  bool isStrikethrough = false;
  bool isUnderline = false;

  int i = 0;

  void addCurrentText() {
    if (currentText.isNotEmpty) {
      spans.add(
        TextSpan(
          text: currentText.toString(),
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : null,
            fontStyle: isItalic ? FontStyle.italic : null,
            decoration: _buildTextDecoration(isStrikethrough, isUnderline),
          ),
        ),
      );
      currentText.clear();
    }
  }

  while (i < input.length) {
    // Check for **bold**
    if (i + 1 < input.length && input.substring(i, i + 2) == '**') {
      addCurrentText();
      isBold = !isBold;
      i += 2;
    }
    // Check for __underline__
    else if (i + 1 < input.length && input.substring(i, i + 2) == '__') {
      addCurrentText();
      isUnderline = !isUnderline;
      i += 2;
    }
    // Check for ~~strikethrough~~
    else if (i + 1 < input.length && input.substring(i, i + 2) == '~~') {
      addCurrentText();
      isStrikethrough = !isStrikethrough;
      i += 2;
    }
    // Check for *italic* (but not if it's part of **)
    else if (input[i] == '*' &&
        (i == 0 || input[i - 1] != '*') &&
        (i + 1 >= input.length || input[i + 1] != '*')) {
      addCurrentText();
      isItalic = !isItalic;
      i += 1;
    } else {
      currentText.write(input[i]);
      i += 1;
    }
  }

  // Add any remaining text
  addCurrentText();

  // If no formatting was applied, return a simple TextSpan
  if (spans.isEmpty) {
    return TextSpan(text: input);
  }

  return TextSpan(children: spans);
}

TextDecoration? _buildTextDecoration(final bool isStrikethrough, final bool isUnderline) {
  if (isStrikethrough && isUnderline) {
    return TextDecoration.combine([
      TextDecoration.lineThrough,
      TextDecoration.underline,
    ]);
  } else if (isStrikethrough) {
    return TextDecoration.lineThrough;
  } else if (isUnderline) {
    return TextDecoration.underline;
  }
  return null;
}
