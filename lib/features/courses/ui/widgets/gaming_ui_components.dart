import 'dart:math' as math;

import 'package:flutter/material.dart';

// Background particle painter with study-friendly colors
class ParticleBackgroundPainter extends CustomPainter {
  final double animationValue;

  ParticleBackgroundPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF2F98D7).withOpacity(0.1) // primary
          ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i + (math.sin(animationValue * 2 + i) * 50);
      final y =
          (size.height / 10) * (i % 10) + (math.cos(animationValue + i) * 30);
      final radius = 2 + math.sin(animationValue * 3 + i) * 2;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw constellation lines
    final linePaint =
        Paint()
          ..color = const Color(0xFF73CBFF).withOpacity(0.05) // lightBlue
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    for (int i = 0; i < 10; i++) {
      final startX = (size.width / 10) * i;
      final startY = size.height * 0.2 + math.sin(animationValue + i) * 100;
      final endX = startX + size.width * 0.2;
      final endY = startY + math.cos(animationValue * 1.5 + i) * 50;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);
    }

    // Draw pulsing grid
    final gridPaint =
        Paint()
          ..color = const Color(0xFFF0F3FF).withOpacity(0.03) // secondary
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

    final gridSize = 50.0;
    final pulse = math.sin(animationValue * 2) * 0.5 + 0.5;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint
          ..color = const Color(
            0xFFF0F3FF,
          ).withOpacity(0.03 * pulse), // secondary
      );
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint
          ..color = const Color(
            0xFFF0F3FF,
          ).withOpacity(0.03 * pulse), // secondary
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Chapter pattern painter with study-friendly colors
class ChapterPatternPainter extends CustomPainter {
  final Color color;

  ChapterPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw geometric pattern - hexagons
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final hexRadius = 20.0;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 5; j++) {
        final x = (size.width / 6) * (j + 1) - hexRadius;
        final y = (size.height / 4) * (i + 1) - hexRadius;
        _drawHexagon(canvas, Offset(x, y), hexRadius * 0.8, paint);
      }
    }

    // Draw connecting diamond patterns
    final diamondPaint =
        Paint()
          ..color = color.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 4; j++) {
        final x = (size.width / 5) * (j + 1);
        final y = (size.height / 3) * (i + 1);
        _drawDiamond(canvas, Offset(x, y), 8, diamondPaint);
      }
    }

    // Draw circuit-like connections
    final circuitPaint =
        Paint()
          ..color = color.withOpacity(0.3)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(20, size.height * 0.3),
      Offset(size.width - 20, size.height * 0.3),
      circuitPaint,
    );
    canvas.drawLine(
      Offset(20, size.height * 0.7),
      Offset(size.width - 20, size.height * 0.7),
      circuitPaint,
    );
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi * 2 / 6) * i;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size, center.dy);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Lesson pattern painter with study-friendly colors
class LessonPatternPainter extends CustomPainter {
  final Color color;

  LessonPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    // Draw concentric circles with tech pattern
    for (int i = 1; i <= 4; i++) {
      final currentRadius = radius * i / 4;
      canvas.drawCircle(center, currentRadius, paint);

      // Add tech nodes on each circle
      final nodeCount = i * 4;
      for (int j = 0; j < nodeCount; j++) {
        final angle = (math.pi * 2 / nodeCount) * j;
        final nodeX = center.dx + math.cos(angle) * currentRadius;
        final nodeY = center.dy + math.sin(angle) * currentRadius;
        canvas.drawCircle(Offset(nodeX, nodeY), 2, paint);
      }
    }

    // Draw radiating energy lines
    for (int i = 0; i < 12; i++) {
      final angle = (math.pi * 2 / 12) * i;
      final startX = center.dx + math.cos(angle) * 15;
      final startY = center.dy + math.sin(angle) * 15;
      final endX = center.dx + math.cos(angle) * radius;
      final endY = center.dy + math.sin(angle) * radius;

      // Dashed line effect
      _drawDashedLine(
        canvas,
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
        dashLength: 5,
        gapLength: 3,
      );
    }

    // Draw inner tech symbol
    final techPaint =
        Paint()
          ..color = color.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    _drawTechSymbol(canvas, center, 12, techPaint);
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    required double dashLength,
    required double gapLength,
  }) {
    final distance = (end - start).distance;
    final totalLength = dashLength + gapLength;
    final dashCount = (distance / totalLength).floor();

    for (int i = 0; i < dashCount; i++) {
      final dashStart = start + (end - start) * (i * totalLength / distance);
      final dashEnd =
          start + (end - start) * ((i * totalLength + dashLength) / distance);
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawTechSymbol(Canvas canvas, Offset center, double size, Paint paint) {
    // Draw a tech-style cross/plus symbol
    canvas.drawLine(
      Offset(center.dx - size, center.dy),
      Offset(center.dx + size, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - size),
      Offset(center.dx, center.dy + size),
      paint,
    );

    // Add corner brackets
    final bracketSize = size * 0.3;
    final corners = [
      Offset(center.dx - size, center.dy - size),
      Offset(center.dx + size, center.dy - size),
      Offset(center.dx - size, center.dy + size),
      Offset(center.dx + size, center.dy + size),
    ];

    for (final corner in corners) {
      canvas.drawLine(
        corner,
        Offset(
          corner.dx + (corner.dx < center.dx ? bracketSize : -bracketSize),
          corner.dy,
        ),
        paint,
      );
      canvas.drawLine(
        corner,
        Offset(
          corner.dx,
          corner.dy + (corner.dy < center.dy ? bracketSize : -bracketSize),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
