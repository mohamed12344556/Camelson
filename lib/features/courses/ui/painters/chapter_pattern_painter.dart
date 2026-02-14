import 'package:simplify/core/constants/roadmap_constants.dart';
import 'package:flutter/material.dart';

class ResponsiveChapterPatternPainter extends CustomPainter {
  final Color color;
  final Size size;
  final RoadmapAnimationStyle style;

  ResponsiveChapterPatternPainter({
    required this.color,
    required this.size,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    switch (style) {
      case RoadmapAnimationStyle.floatingOrbs:
        _drawOrbPattern(canvas, canvasSize);
        break;
      case RoadmapAnimationStyle.timeline:
        _drawTimelinePattern(canvas, canvasSize);
        break;
    }
  }

  void _drawOrbPattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw floating orb connections
    for (int i = 0; i < 4; i++) {
      final centerX = (canvasSize.width / 5) * (i + 1);
      final centerY = canvasSize.height / 2;

      canvas.drawCircle(Offset(centerX, centerY), 8, paint);

      if (i > 0) {
        final prevX = (canvasSize.width / 5) * i;
        canvas.drawLine(
          Offset(prevX, centerY),
          Offset(centerX, centerY),
          paint,
        );
      }
    }
  }

  void _drawTimelinePattern(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw timeline markers
    final centerX = canvasSize.width / 2;

    for (int i = 0; i < 3; i++) {
      final y = (canvasSize.height / 4) * (i + 1);

      // Draw timeline marker
      canvas.drawLine(Offset(centerX - 15, y), Offset(centerX + 15, y), paint);

      // Draw marker diamond
      final path = Path();
      path.moveTo(centerX, y - 5);
      path.lineTo(centerX + 5, y);
      path.lineTo(centerX, y + 5);
      path.lineTo(centerX - 5, y);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
