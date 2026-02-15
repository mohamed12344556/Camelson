import 'package:boraq/features/courses/data/models/roadmap_data_models.dart';
import 'package:flutter/material.dart';

import '../../data/models/subject_roadmap_model.dart';

// Timeline Progress Painter
class TimelineProgressPainter extends CustomPainter {
  final List<RoadmapItemData> items;
  final List<Animation<double>> timelineAnimations;
  final List<Animation<double>> connectionAnimations;
  final double itemSize;
  final double chapterWidth;
  final double chapterHeight;
  final double screenWidth;
  final double spacing;
  final double scrollOffset; // إضافة scroll offset

  TimelineProgressPainter({
    required this.items,
    required this.timelineAnimations,
    required this.connectionAnimations,
    required this.itemSize,
    required this.chapterWidth,
    required this.chapterHeight,
    required this.screenWidth,
    required this.spacing,
    this.scrollOffset = 0.0, // قيمة افتراضية
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw main timeline spine
    _drawTimelineSpine(canvas, size);

    // Draw progress indicators and milestones
    _drawTimelineProgress(canvas, size);
  }

  void _drawTimelineSpine(Canvas canvas, Size size) {
    final spinePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF667eea)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spineX = screenWidth / 2;
    canvas.drawLine(Offset(spineX, 0), Offset(spineX, size.height), spinePaint);

    // Draw timeline grid lines
    _drawTimelineGrid(canvas, size, spineX);
  }

  void _drawTimelineGrid(Canvas canvas, Size size, double spineX) {
    final gridPaint = Paint()
      ..color = const Color(0xFF667eea).withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double currentY = chapterHeight / 2;
    int itemIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final animationValue = itemIndex < timelineAnimations.length
          ? timelineAnimations[itemIndex].value
          : 1.0;

      if (animationValue > 0) {
        // Draw horizontal grid line
        final lineLength = 50 * animationValue;
        canvas.drawLine(
          Offset(spineX - lineLength, currentY),
          Offset(spineX + lineLength, currentY),
          gridPaint,
        );

        // Draw timeline markers
        final markerPaint = Paint()
          ..color = const Color(0xFF764ba2).withOpacity(animationValue)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(spineX, currentY),
          6 * animationValue,
          markerPaint,
        );
      }

      currentY +=
          spacing +
          (item.type == RoadmapItemType.chapter ? chapterHeight : itemSize);
      itemIndex++;
    }
  }

  void _drawTimelineProgress(Canvas canvas, Size size) {
    double currentY = chapterHeight / 2;
    int completedItems = 0;
    int totalItems = items.length;

    // Count completed items
    for (var item in items) {
      if (item.type == RoadmapItemType.lesson && item.lesson!.isCompleted) {
        completedItems++;
      } else if (item.type == RoadmapItemType.chapter &&
          item.chapter!.isCompleted) {
        completedItems++;
      }
    }

    // Draw overall progress bar
    final progressHeight = (completedItems / totalItems) * size.height;
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, progressHeight))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final spineX = screenWidth / 2;
    canvas.drawLine(
      Offset(spineX, size.height - progressHeight),
      Offset(spineX, size.height),
      progressPaint,
    );

    // Draw milestone indicators
    _drawMilestones(canvas, size, spineX);
  }

  void _drawMilestones(Canvas canvas, Size size, double spineX) {
    double currentY = chapterHeight / 2;
    int itemIndex = 0;

    for (var item in items) {
      final animationValue = itemIndex < timelineAnimations.length
          ? timelineAnimations[itemIndex].value
          : 1.0;

      if (item.type == RoadmapItemType.chapter) {
        // Draw chapter milestone
        _drawChapterMilestone(
          canvas,
          Offset(spineX, currentY),
          item.chapter!,
          animationValue,
        );
      } else {
        // Draw lesson milestone
        _drawLessonMilestone(
          canvas,
          Offset(spineX, currentY),
          item.lesson!,
          animationValue,
          itemIndex,
        );
      }

      currentY +=
          spacing +
          (item.type == RoadmapItemType.chapter ? chapterHeight : itemSize);
      itemIndex++;
    }
  }

  void _drawChapterMilestone(
    Canvas canvas,
    Offset position,
    ChapterModel chapter,
    double animation,
  ) {
    final milestonePaint = Paint()
      ..color = chapter.isCompleted
          ? const Color(0xFF4CAF50)
          : chapter.isLocked
          ? const Color(0xFFBDBDBD)
          : const Color(0xFF667eea)
      ..style = PaintingStyle.fill;

    final milestoneSize = 15 * animation;

    // Draw milestone diamond
    final path = Path();
    path.moveTo(position.dx, position.dy - milestoneSize);
    path.lineTo(position.dx + milestoneSize, position.dy);
    path.lineTo(position.dx, position.dy + milestoneSize);
    path.lineTo(position.dx - milestoneSize, position.dy);
    path.close();

    canvas.drawPath(path, milestonePaint);

    // Draw milestone glow if completed
    if (chapter.isCompleted && animation > 0.5) {
      final glowPaint = Paint()
        ..color = const Color(0xFF4CAF50).withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawPath(path, glowPaint);
    }
  }

  void _drawLessonMilestone(
    Canvas canvas,
    Offset position,
    LessonModel lesson,
    double animation,
    int index,
  ) {
    final isLeft = index % 2 == 0;
    final milestoneX = position.dx + (isLeft ? -30 : 30);
    final milestonePosition = Offset(milestoneX, position.dy);

    // حساب visibility بناءً على الـ scroll
    final visibilityFactor = _calculateVisibility(position.dy);
    final finalAnimation = animation * visibilityFactor;

    final milestonePaint = Paint()
      ..color = lesson.isCompleted
          ? const Color(0xFF4CAF50)
          : lesson.isCurrent
          ? const Color(0xFF2196F3)
          : lesson.isLocked
          ? const Color(0xFFBDBDBD)
          : const Color(0xFF9C27B0)
      ..style = PaintingStyle.fill;

    final milestoneSize = 8 * finalAnimation;
    if (milestoneSize > 0) {
      canvas.drawCircle(milestonePosition, milestoneSize, milestonePaint);

      // Draw connection line to main timeline
      if (finalAnimation > 0.3) {
        final connectionPaint = Paint()
          ..color = const Color(0xFF667eea).withOpacity(0.5 * finalAnimation)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        canvas.drawLine(position, milestonePosition, connectionPaint);
      }

      // Draw lesson type indicator
      if (finalAnimation > 0.7) {
        _drawLessonTypeIndicator(
          canvas,
          milestonePosition,
          lesson.type,
          milestoneSize,
        );
      }
    }
  }

  // إضافة دالة لحساب الـ visibility
  double _calculateVisibility(double itemY) {
    const double screenCenter = 400; // تقريبي لمركز الشاشة
    const double visibilityRange = 300; // المدى اللي العناصر تظهر فيه

    final distance = (itemY + scrollOffset - screenCenter).abs();
    if (distance > visibilityRange) return 0.0;

    return 1.0 - (distance / visibilityRange);
  }

  void _drawLessonTypeIndicator(
    Canvas canvas,
    Offset position,
    LessonType type,
    double size,
  ) {
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    switch (type) {
      case LessonType.video:
        // Draw play triangle
        final path = Path();
        path.moveTo(position.dx - size * 0.3, position.dy - size * 0.3);
        path.lineTo(position.dx + size * 0.4, position.dy);
        path.lineTo(position.dx - size * 0.3, position.dy + size * 0.3);
        path.close();
        canvas.drawPath(path, indicatorPaint);
        break;
      case LessonType.quiz:
        // Draw question mark
        canvas.drawCircle(
          Offset(position.dx, position.dy - size * 0.2),
          size * 0.2,
          indicatorPaint,
        );
        canvas.drawCircle(
          Offset(position.dx, position.dy + size * 0.3),
          size * 0.1,
          indicatorPaint,
        );
        break;
      case LessonType.assignment:
        // Draw checkmark
        final path = Path();
        path.moveTo(position.dx - size * 0.3, position.dy);
        path.lineTo(position.dx - size * 0.1, position.dy + size * 0.2);
        path.lineTo(position.dx + size * 0.3, position.dy - size * 0.2);
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.white
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round,
        );
        break;
      case LessonType.reading:
        // Draw book pages
        final bookPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;

        canvas.drawLine(
          Offset(position.dx - size * 0.2, position.dy - size * 0.3),
          Offset(position.dx - size * 0.2, position.dy + size * 0.3),
          bookPaint,
        );
        canvas.drawLine(
          Offset(position.dx + size * 0.2, position.dy - size * 0.3),
          Offset(position.dx + size * 0.2, position.dy + size * 0.3),
          bookPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
