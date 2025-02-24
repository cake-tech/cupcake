import 'dart:math';

import 'package:cupcake/views/widgets/barcode_scanner/urqr_progress.dart';
import 'package:flutter/material.dart';

class ProgressPainter extends CustomPainter {
  ProgressPainter({required this.urQrProgress});
  final URQrProgress urQrProgress;

  @override
  void paint(final Canvas canvas, final Size size) {
    final c = Offset(size.width / 2.0, size.height / 2.0);
    final radius = size.width * 0.9;
    final rect = Rect.fromCenter(center: c, width: radius, height: radius);
    const fullAngle = 360.0;
    var startAngle = 0.0;
    for (int i = 0; i < urQrProgress.expectedPartCount.toInt(); i++) {
      final sweepAngle = (1 / urQrProgress.expectedPartCount) * fullAngle * pi / 180.0;
      drawSector(
        canvas,
        urQrProgress.receivedPartIndexes.contains(i),
        rect,
        startAngle,
        sweepAngle,
      );
      startAngle += sweepAngle;
    }
  }

  void drawSector(
    final Canvas canvas,
    final bool isActive,
    final Rect rect,
    final double startAngle,
    final double sweepAngle,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = isActive ? const Color(0xffff6600) : Colors.white70;
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant final ProgressPainter oldDelegate) {
    return urQrProgress != oldDelegate.urQrProgress;
  }
}
