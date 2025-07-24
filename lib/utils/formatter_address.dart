import 'package:flutter/material.dart';

TextSpan formattedAddress(final String address) {
  final List<TextSpan> spans = [];
  int index = 0;
  bool isWhiteGroup = true;

  while (index < address.length) {
    final int endIndex = (index + 6).clamp(0, address.length);
    final String chunk = address.substring(index, endIndex);

    spans.add(
      TextSpan(
        text: chunk,
        style: TextStyle(
          color: isWhiteGroup ? Colors.white : Colors.grey,
        ),
      ),
    );

    if (endIndex < address.length) {
      spans.add(
        const TextSpan(
          text: ' ',
          style: TextStyle(color: Colors.transparent),
        ),
      );
    }

    index = endIndex;
    isWhiteGroup = !isWhiteGroup;
  }

  return TextSpan(children: spans);
}
