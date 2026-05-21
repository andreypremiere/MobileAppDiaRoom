import 'dart:math';
import 'package:flutter/material.dart';

class DiaRoomLoaderPainter extends CustomPainter {
  final Color color;

  // Конструктор теперь принимает только цвет, анимацию мы вынесли наружу
  DiaRoomLoaderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 3; // чуть тоньше

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5 // Изящная тонкая линия
      ..strokeCap = StrokeCap.butt // Прямой срез, чтобы градиент не артефактил
      ..shader = SweepGradient(
        // Градиент от полной прозрачности до полного цвета
        colors: [
          color.withOpacity(0.0), // Хвост
          color,                  // Голова
        ],
        stops: const [0.1, 1.0], // Небольшая задержка перед началом цвета для мягкости
        // Разворачиваем градиент, чтобы голова была сверху при повороте 0
        transform: const GradientRotation(-pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Рисуем почти полную дугу (она всегда статична относительно шейдера)
    // Мы оставляем крошечный разрыв, чтобы градиент не "схлопывался"
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      1.95 * pi, // Почти полный круг (0.975 от 2*PI)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant DiaRoomLoaderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}