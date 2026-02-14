import 'dart:math' as math;

import 'package:simplify/features/courses/data/models/roadmap_data_models.dart';
import 'package:flutter/material.dart';

// Floating Orbs Painter
class FloatingOrbsPainter extends CustomPainter {
  final List<RoadmapItemData> items;
  final List<Animation<double>> connectionAnimations;
  final List<Animation<double>> orbAnimations;
  final double itemSize;
  final double chapterWidth;
  final double chapterHeight;
  final double screenWidth;
  final double spacing;

  FloatingOrbsPainter({
    required this.items,
    required this.connectionAnimations,
    required this.orbAnimations,
    required this.itemSize,
    required this.chapterWidth,
    required this.chapterHeight,
    required this.screenWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double currentY = chapterHeight / 2;

    for (int i = 0; i < items.length - 1; i++) {
      if (i >= connectionAnimations.length || i >= orbAnimations.length)
        continue;

      final currentItem = items[i];
      final nextItem = items[i + 1];

      double startX, endX, startY, endY;

      if (currentItem.type == RoadmapItemType.chapter) {
        startX = screenWidth / 2;
        startY = currentY + chapterHeight / 2;
      } else {
        startX = (i % 2 == 0) ? itemSize / 2 : screenWidth - itemSize / 2;
        startY = currentY + itemSize / 2;
      }

      currentY +=
          spacing +
          (currentItem.type == RoadmapItemType.chapter
              ? chapterHeight
              : itemSize);

      if (nextItem.type == RoadmapItemType.chapter) {
        endX = screenWidth / 2;
        endY = currentY + chapterHeight / 2;
      } else {
        endX = ((i + 1) % 2 == 0) ? itemSize / 2 : screenWidth - itemSize / 2;
        endY = currentY + itemSize / 2;
      }

      _drawFloatingOrbsBridge(
        canvas,
        Offset(startX, startY),
        Offset(endX, endY),
        connectionAnimations[i].value,
        orbAnimations[i].value,
      );
    }
  }

  void _drawFloatingOrbsBridge(
    Canvas canvas,
    Offset start,
    Offset end,
    double connectionProgress,
    double orbProgress,
  ) {
    // Draw energy bridge
    final bridgePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF64B5F6).withOpacity(0.6),
          const Color(0xFF1976D2).withOpacity(0.8),
          const Color(0xFF64B5F6).withOpacity(0.6),
        ],
      ).createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final animatedEnd = Offset.lerp(start, end, connectionProgress)!;
    canvas.drawLine(start, animatedEnd, bridgePaint);

    // Draw floating orbs
    _drawFloatingOrbs(canvas, start, end, connectionProgress, orbProgress);
  }

  void _drawFloatingOrbs(
    Canvas canvas,
    Offset start,
    Offset end,
    double connectionProgress,
    double orbProgress,
  ) {
    const orbCount = 5;
    const orbSize = 6.0;

    for (int i = 0; i < orbCount; i++) {
      final baseProgress = (i / (orbCount - 1)) * connectionProgress;
      final floatOffset = math.sin(orbProgress * 4 + i) * 15;

      if (baseProgress > 0) {
        final basePosition = Offset.lerp(start, end, baseProgress)!;
        final orbPosition = Offset(
          basePosition.dx + math.cos(orbProgress * 3 + i) * 10,
          basePosition.dy + floatOffset,
        );

        // Draw orb glow
        final glowPaint = Paint()
          ..shader =
              RadialGradient(
                colors: [
                  const Color(0xFF64B5F6).withOpacity(0.8),
                  const Color(0xFF1976D2).withOpacity(0.4),
                  Colors.transparent,
                ],
              ).createShader(
                Rect.fromCircle(center: orbPosition, radius: orbSize * 3),
              )
          ..style = PaintingStyle.fill;

        canvas.drawCircle(orbPosition, orbSize * 3, glowPaint);

        // Draw orb core
        final orbPaint = Paint()
          ..shader = RadialGradient(
            colors: [const Color(0xFF90CAF9), const Color(0xFF1976D2)],
          ).createShader(Rect.fromCircle(center: orbPosition, radius: orbSize))
          ..style = PaintingStyle.fill;

        canvas.drawCircle(orbPosition, orbSize, orbPaint);

        // Draw orb highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(
            orbPosition.dx - orbSize * 0.3,
            orbPosition.dy - orbSize * 0.3,
          ),
          orbSize * 0.3,
          highlightPaint,
        );

        // Draw connecting tendrils to nearby orbs
        if (i > 0) {
          final prevProgress = ((i - 1) / (orbCount - 1)) * connectionProgress;
          final prevBasePosition = Offset.lerp(start, end, prevProgress)!;
          final prevOrbPosition = Offset(
            prevBasePosition.dx + math.cos(orbProgress * 3 + (i - 1)) * 10,
            prevBasePosition.dy + math.sin(orbProgress * 4 + (i - 1)) * 15,
          );

          final tendrilPaint = Paint()
            ..color = const Color(0xFF64B5F6).withOpacity(0.4)
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke;

          canvas.drawLine(prevOrbPosition, orbPosition, tendrilPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
