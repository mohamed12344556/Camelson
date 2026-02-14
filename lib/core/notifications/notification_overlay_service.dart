import 'package:flutter/material.dart';
import 'glassmorphism_notification.dart';

class NotificationOverlayService {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required NotificationType type,
    String? senderName,
    Duration duration = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    if (_isShowing && _currentOverlay != null) {
      try {
        _currentOverlay?.remove();
        _currentOverlay = null;
      } catch (e) {
        // Already removed
      }
    }

    _isShowing = true;

    _currentOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: GlassmorphismNotification(
            title: title,
            message: message,
            type: type,
            senderName: senderName,
            duration: duration,
            onTap: onTap,
            onDismiss: () {
              dismiss();
            },
          ),
        ),
      ),
    );

    try {
      final overlay = Navigator.of(context, rootNavigator: true).overlay;
      if (overlay != null) {
        overlay.insert(_currentOverlay!);
      }
    } catch (e) {
      try {
        Overlay.of(context, rootOverlay: true).insert(_currentOverlay!);
      } catch (e) {
        _isShowing = false;
        _currentOverlay = null;
      }
    }
  }

  static void dismiss() {
    if (_isShowing && _currentOverlay != null) {
      try {
        _currentOverlay?.remove();
      } catch (e) {
        // Ignore
      } finally {
        _currentOverlay = null;
        _isShowing = false;
      }
    }
  }

  // درس جديد
  static void showNewLesson({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.newLesson,
      onTap: onTap,
    );
  }

  // امتحان
  static void showExam({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.exam,
      onTap: onTap,
    );
  }

  // تذكير بموعد
  static void showLessonReminder({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.lessonReminder,
      onTap: onTap,
    );
  }

  // رسالة شات
  static void showChatMessage({
    required BuildContext context,
    required String senderName,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: 'رسالة جديدة',
      message: message,
      type: NotificationType.chatMessage,
      senderName: senderName,
      onTap: onTap,
    );
  }

  // منشور كوميونيتي
  static void showCommunityPost({
    required BuildContext context,
    required String userName,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: 'منشور جديد',
      message: message,
      type: NotificationType.communityPost,
      senderName: userName,
      onTap: onTap,
    );
  }

  // مسابقة
  static void showCompetition({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.competition,
      onTap: onTap,
    );
  }

  // إنجاز
  static void showAchievement({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.achievement,
      duration: const Duration(seconds: 6),
      onTap: onTap,
    );
  }

  // بث مباشر
  static void showLiveStream({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.liveStream,
      onTap: onTap,
    );
  }

  // واجب
  static void showHomework({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.homework,
      onTap: onTap,
    );
  }

  // درجة/نتيجة
  static void showGrade({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.grade,
      onTap: onTap,
    );
  }
}
