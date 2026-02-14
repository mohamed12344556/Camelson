import 'package:flutter/material.dart';

// Animation Styles Enum
enum RoadmapAnimationStyle { timeline, floatingOrbs }

// Style Configuration
class RoadmapStyleConfig {
  // Colors for Timeline Style
  static const timelineColors = RoadmapColors(
    primary: Color(0xFF667eea),
    secondary: Color(0xFF764ba2),
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF5F7FA), Color(0xFFC3CFE2), Color(0xFF667eea)],
    ),
    chapterGradient: LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    chapterBorder: Color(0xFF764ba2),
    progressColor: Color(0xFFAB47BC),
    progressBackground: Color(0xFF2C3E50),
    textColor: Colors.white,
  );

  // Colors for Floating Orbs Style
  static const floatingOrbsColors = RoadmapColors(
    primary: Color(0xFF1E3C72),
    secondary: Color(0xFF3B7DD8),
    background: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF3B7DD8)],
    ),
    chapterGradient: LinearGradient(
      colors: [Color(0xFF1E3C72), Color(0xFF2A5298), Color(0xFF3B7DD8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    chapterBorder: Color(0xFF3B7DD8),
    progressColor: Color(0xFF64B5F6),
    progressBackground: Color(0xFF0D1B2A),
    textColor: Colors.white,
  );

  static RoadmapColors getColors(RoadmapAnimationStyle style) {
    switch (style) {
      case RoadmapAnimationStyle.timeline:
        return timelineColors;
      case RoadmapAnimationStyle.floatingOrbs:
        return floatingOrbsColors;
    }
  }

  static IconData getIcon(RoadmapAnimationStyle style) {
    switch (style) {
      case RoadmapAnimationStyle.timeline:
        return Icons.timeline;
      case RoadmapAnimationStyle.floatingOrbs:
        return Icons.bubble_chart;
    }
  }

  static String getName(RoadmapAnimationStyle style) {
    switch (style) {
      case RoadmapAnimationStyle.timeline:
        return 'خط زمني';
      case RoadmapAnimationStyle.floatingOrbs:
        return 'كرات عائمة';
    }
  }
}

class RoadmapColors {
  final Color primary;
  final Color secondary;
  final LinearGradient background;
  final LinearGradient chapterGradient;
  final Color chapterBorder;
  final Color progressColor;
  final Color progressBackground;
  final Color textColor;

  const RoadmapColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.chapterGradient,
    required this.chapterBorder,
    required this.progressColor,
    required this.progressBackground,
    required this.textColor,
  });
}

// Size Constants
class RoadmapSizes {
  static double getItemSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 140;
    if (screenWidth > 600) return 120;
    return 100;
  }

  static double getChapterWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 350;
    if (screenWidth > 600) return 300;
    return screenWidth * 0.85;
  }

  static double getChapterHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 140;
    if (screenWidth > 600) return 120;
    return screenWidth * 0.3;
  }

  static double getSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 80;
    if (screenWidth > 600) return 60;
    return screenWidth * 0.05;
  }

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > 600;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > 1200;
}

// Animation Durations
class AnimationDurations {
  static const Duration itemAnimation = Duration(milliseconds: 800);
  static const Duration connectionAnimation = Duration(milliseconds: 2000);
  static const Duration pulseAnimation = Duration(milliseconds: 1500);
  static const Duration flowAnimation = Duration(milliseconds: 3000);
  static const Duration orbAnimation = Duration(milliseconds: 4000);
  static const Duration timelineAnimation = Duration(milliseconds: 2500);
}
