import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProgressPainter extends CustomPainter {
  final URQrProgress urQrProgress;

  ProgressPainter({required this.urQrProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.9;
    final rect = Rect.fromCenter(center: c, width: radius, height: radius);
    const fullAngle = 360.0;
    var startAngle = 0.0;
    for (int i = 0; i < urQrProgress.expectedPartCount.toInt(); i++) {
      var sweepAngle =
          (1 / urQrProgress.expectedPartCount) * fullAngle * pi / 180.0;
      drawSector(canvas, urQrProgress.receivedPartIndexes.contains(i), rect,
          startAngle, sweepAngle);
      startAngle += sweepAngle;
    }
  }

  void drawSector(Canvas canvas, bool isActive, Rect rect, double startAngle,
      double sweepAngle) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isActive ? const Color(0xffff6600) : Colors.white70;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant ProgressPainter oldDelegate) {
    return urQrProgress != oldDelegate.urQrProgress;
  }
}

class URQrProgress {
  int expectedPartCount;
  int processedPartsCount;
  List<int> receivedPartIndexes;
  double percentage;

  URQrProgress({
    required this.expectedPartCount,
    required this.processedPartsCount,
    required this.receivedPartIndexes,
    required this.percentage,
  });

  bool equals(URQrProgress? progress) {
    if (progress == null) {
      return false;
    }
    return processedPartsCount == progress.processedPartsCount;
  }
}