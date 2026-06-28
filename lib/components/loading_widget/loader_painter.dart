import 'dart:math';
import 'package:flutter/material.dart';

class DiaRoomLoaderPainter extends CustomPainter {
  final Color color;

  DiaRoomLoaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 3;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.butt
      ..shader = SweepGradient(
        colors: [
          color.withOpacity(0.0),
          color,
        ],
        stops: const [0.1, 1.0],
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      1.95 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant DiaRoomLoaderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}