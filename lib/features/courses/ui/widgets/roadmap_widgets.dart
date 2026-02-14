import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/roadmap_constants.dart';
import '../../data/models/subject_roadmap_model.dart';
import '../painters/chapter_pattern_painter.dart';

class RoadmapChapterWidget extends StatelessWidget {
  final ChapterModel chapter;
  final int index;
  final RoadmapAnimationStyle style;
  final double animationValue;
  final VoidCallback onTap;

  const RoadmapChapterWidget({
    super.key,
    required this.chapter,
    required this.index,
    required this.style,
    required this.animationValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoadmapStyleConfig.getColors(style);
    final chapterWidth = RoadmapSizes.getChapterWidth(context);
    final chapterHeight = RoadmapSizes.getChapterHeight(context);
    final isDesktop = RoadmapSizes.isDesktop(context);
    final isTablet = RoadmapSizes.isTablet(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Transform.translate(
        offset: Offset(0, 50 * (1 - animationValue)),
        child: Transform.scale(
          scale: 0.3 + (0.7 * animationValue),
          child: Opacity(
            opacity: animationValue,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Enhanced glow effect based on style
                Container(
                  width: chapterWidth + 40,
                  height: chapterHeight + 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: _getChapterGlow(colors),
                  ),
                ),

                // Main container
                Container(
                  width: chapterWidth,
                  height: chapterHeight,
                  decoration: BoxDecoration(
                    gradient: colors.chapterGradient,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: colors.chapterBorder.withOpacity(0.6),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern based on style
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ResponsiveChapterPatternPainter(
                            color: colors.textColor.withOpacity(0.15),
                            size: Size(chapterWidth, chapterHeight),
                            style: style,
                          ),
                        ),
                      ),

                      // Chapter content
                      Padding(
                        padding: EdgeInsets.all(
                          isDesktop
                              ? 24
                              : isTablet
                              ? 20
                              : 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.progressBackground
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'فصل ${chapter.chapterNumber}',
                                      style: TextStyle(
                                        color: colors.textColor,
                                        fontSize:
                                            isDesktop
                                                ? 14
                                                : isTablet
                                                ? 12
                                                : 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: isDesktop ? 12 : 8),
                                  Text(
                                    chapter.chapterName,
                                    style: TextStyle(
                                      color: colors.textColor,
                                      fontSize:
                                          isDesktop
                                              ? 20
                                              : isTablet
                                              ? 18
                                              : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: isDesktop ? 8 : 4),
                                  Text(
                                    '${chapter.lessons.length} درس',
                                    style: TextStyle(
                                      color: colors.textColor.withOpacity(0.8),
                                      fontSize:
                                          isDesktop
                                              ? 16
                                              : isTablet
                                              ? 14
                                              : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Progress circle
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      isDesktop
                                          ? 80
                                          : isTablet
                                          ? 70
                                          : 64,
                                  height:
                                      isDesktop
                                          ? 80
                                          : isTablet
                                          ? 70
                                          : 64,
                                  child: CircularProgressIndicator(
                                    value: (chapter.progress / 100).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    strokeWidth:
                                        isDesktop
                                            ? 7
                                            : isTablet
                                            ? 6
                                            : 5,
                                    backgroundColor: colors.progressBackground
                                        .withOpacity(0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      colors.progressColor,
                                    ),
                                  ),
                                ),
                                Container(
                                  width:
                                      isDesktop
                                          ? 60
                                          : isTablet
                                          ? 50
                                          : 40,
                                  height:
                                      isDesktop
                                          ? 60
                                          : isTablet
                                          ? 50
                                          : 40,
                                  decoration: BoxDecoration(
                                    color: colors.progressBackground
                                        .withOpacity(0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.progressColor.withOpacity(
                                        0.5,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${chapter.progress.toInt()}%',
                                        style: TextStyle(
                                          color: colors.progressColor,
                                          fontSize:
                                              isDesktop
                                                  ? 14
                                                  : isTablet
                                                  ? 12
                                                  : 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Icon(
                                        Icons.school,
                                        color: const Color(0xFFFF6B35),
                                        size:
                                            isDesktop
                                                ? 16
                                                : isTablet
                                                ? 14
                                                : 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Lock overlay
                      if (chapter.isLocked)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF505050).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.lock,
                                color: const Color(0xFFE6E6E6),
                                size:
                                    isDesktop
                                        ? 40
                                        : isTablet
                                        ? 35
                                        : 30,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _getChapterGlow(RoadmapColors colors) {
    switch (style) {
      case RoadmapAnimationStyle.floatingOrbs:
        return [
          BoxShadow(
            color: colors.primary.withOpacity(0.3),
            blurRadius: 35,
            spreadRadius: 6,
          ),
        ];
      case RoadmapAnimationStyle.timeline:
        return [
          BoxShadow(
            color: colors.primary.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ];
    }
  }
}

class RoadmapLessonWidget extends StatelessWidget {
  final LessonModel lesson;
  final ChapterModel chapter;
  final int index;
  final RoadmapAnimationStyle style;
  final double animationValue;
  final Animation<double>? pulseAnimation;
  final Function(LessonModel, ChapterModel) onTap;

  const RoadmapLessonWidget({
    super.key,
    required this.lesson,
    required this.chapter,
    required this.index,
    required this.style,
    required this.animationValue,
    this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = RoadmapStyleConfig.getColors(style);
    final itemSize = RoadmapSizes.getItemSize(context);
    final isDesktop = RoadmapSizes.isDesktop(context);
    final isTablet = RoadmapSizes.isTablet(context);

    final Color primaryColor =
        lesson.isCompleted
            ? const Color(0xFF4CAF50)
            : lesson.isCurrent
            ? colors.primary
            : lesson.isLocked
            ? const Color(0xFFE6E6E6)
            : colors.secondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(lesson, chapter);
      },
      child: Transform.translate(
        offset: Offset(0, 50 * (1 - animationValue)),
        child: Transform.scale(
          scale: 0.3 + (0.7 * animationValue),
          child: Opacity(
            opacity: animationValue,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse animation for current lesson
                if (lesson.isCurrent && pulseAnimation != null)
                  AnimatedBuilder(
                    animation: pulseAnimation!,
                    builder: (context, child) {
                      final pulseValue = pulseAnimation!.value.clamp(0.0, 1.0);
                      return Container(
                        width: itemSize + (30 * pulseValue),
                        height: itemSize + (30 * pulseValue),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(
                              (0.4 * (1 - pulseValue)).clamp(0.0, 1.0),
                            ),
                            width: 3,
                          ),
                        ),
                      );
                    },
                  ),

                // Main lesson container
                Container(
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    gradient:
                        lesson.isLocked
                            ? LinearGradient(
                              colors: [
                                const Color(0xFFE6E6E6),
                                const Color(0xFFE6E6E6).withOpacity(0.8),
                              ],
                            )
                            : LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withOpacity(0.8),
                                primaryColor.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          lesson.isCurrent
                              ? colors.primary
                              : primaryColor.withOpacity(0.5),
                      width: lesson.isCurrent ? 4 : 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Content
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min, // إضافة هذا السطر
                        children: [
                          Container(
                            padding: EdgeInsets.all(
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getLessonIconBackgroundColor(colors),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getLessonIcon(lesson.type),
                              size:
                                  isDesktop
                                      ? 28
                                      : isTablet
                                      ? 24
                                      : 20,
                              color: _getLessonIconColor(colors),
                            ),
                          ),
                          SizedBox(
                            height:
                                isDesktop
                                    ? 8
                                    : isTablet
                                    ? 6
                                    : 4,
                          ),
                          Text(
                            'درس ${lesson.lessonNumber}',
                            style: TextStyle(
                              fontSize:
                                  isDesktop
                                      ? 12
                                      : isTablet
                                      ? 11
                                      : 10,
                              fontWeight: FontWeight.bold,
                              color: _getLessonTextColor(colors),
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            _getLessonTypeName(lesson.type),
                            style: TextStyle(
                              fontSize:
                                  isDesktop
                                      ? 10
                                      : isTablet
                                      ? 9
                                      : 8,
                              color: _getLessonTextColor(
                                colors,
                              ).withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),

                      // Status indicators
                      if (lesson.isCompleted)
                        Positioned(
                          top:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          right:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          child: Container(
                            width:
                                isDesktop
                                    ? 28
                                    : isTablet
                                    ? 24
                                    : 20,
                            height:
                                isDesktop
                                    ? 28
                                    : isTablet
                                    ? 24
                                    : 20,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size:
                                  isDesktop
                                      ? 18
                                      : isTablet
                                      ? 16
                                      : 14,
                            ),
                          ),
                        ),

                      if (lesson.isLocked)
                        Positioned(
                          top:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          right:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          child: Container(
                            width:
                                isDesktop
                                    ? 28
                                    : isTablet
                                    ? 24
                                    : 20,
                            height:
                                isDesktop
                                    ? 28
                                    : isTablet
                                    ? 24
                                    : 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF505050),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock,
                              color: const Color(0xFFE6E6E6),
                              size:
                                  isDesktop
                                      ? 18
                                      : isTablet
                                      ? 16
                                      : 14,
                            ),
                          ),
                        ),

                      if (lesson.isCurrent)
                        Positioned(
                          top:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          left:
                              isDesktop
                                  ? 10
                                  : isTablet
                                  ? 8
                                  : 6,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 6 : 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFFF8A50)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الآن',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isDesktop ? 8 : 7,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                      // Points Badge
                      Positioned(
                        bottom: isDesktop ? 5 : 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                isDesktop
                                    ? 8
                                    : isTablet
                                    ? 6
                                    : 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+${lesson.xpReward} نقطة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isDesktop
                                      ? 10
                                      : isTablet
                                      ? 9
                                      : 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLessonIconBackgroundColor(RoadmapColors colors) {
    switch (style) {
      case RoadmapAnimationStyle.floatingOrbs:
        return const Color(0xFF0D1B2A).withOpacity(0.4);
      case RoadmapAnimationStyle.timeline:
        return const Color(0xFFF5F7FA).withOpacity(0.9);
    }
  }

  Color _getLessonIconColor(RoadmapColors colors) {
    switch (style) {
      case RoadmapAnimationStyle.floatingOrbs:
        return Colors.white;
      case RoadmapAnimationStyle.timeline:
        return colors.primary;
    }
  }

  Color _getLessonTextColor(RoadmapColors colors) {
    switch (style) {
      case RoadmapAnimationStyle.floatingOrbs:
        return Colors.white;
      case RoadmapAnimationStyle.timeline:
        return Colors.white;
    }
  }

  IconData _getLessonIcon(LessonType type) {
    switch (type) {
      case LessonType.video:
        return Icons.play_circle_filled;
      case LessonType.quiz:
        return Icons.quiz;
      case LessonType.assignment:
        return Icons.assignment;
      case LessonType.reading:
        return Icons.menu_book;
    }
  }

  String _getLessonTypeName(LessonType type) {
    switch (type) {
      case LessonType.video:
        return 'مشاهدة';
      case LessonType.quiz:
        return 'اختبار';
      case LessonType.assignment:
        return 'مهمة';
      case LessonType.reading:
        return 'قراءة';
    }
  }
}
