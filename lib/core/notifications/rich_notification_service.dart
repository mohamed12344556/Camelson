import 'package:flutter/material.dart';
import 'rich_notification.dart';

class RichNotificationService {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required NotificationType type,
    String? avatarUrl,
    String? senderName,
    String? timeAgo,
    String? badge,
    Duration duration = const Duration(seconds: 6),
    VoidCallback? onTap,
    VoidCallback? onAction,
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
          child: RichNotification(
            title: title,
            message: message,
            type: type,
            avatarUrl: avatarUrl,
            senderName: senderName,
            timeAgo: timeAgo,
            badge: badge,
            duration: duration,
            onTap: onTap,
            onAction: onAction,
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
    String? badge,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.newLesson,
      badge: badge ?? 'جديد',
      timeAgo: 'الآن',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // امتحان
  static void showExam({
    required BuildContext context,
    required String title,
    required String message,
    String? timeAgo,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.exam,
      badge: 'امتحان',
      timeAgo: timeAgo ?? 'غداً',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // رسالة شات
  static void showChatMessage({
    required BuildContext context,
    required String senderName,
    required String message,
    String? avatarUrl,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: 'رسالة جديدة',
      message: message,
      type: NotificationType.chatMessage,
      senderName: senderName,
      avatarUrl: avatarUrl,
      timeAgo: 'الآن',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // بث مباشر
  static void showLiveStream({
    required BuildContext context,
    required String title,
    required String message,
    String? senderName,
    String? avatarUrl,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.liveStream,
      senderName: senderName,
      avatarUrl: avatarUrl,
      badge: 'LIVE',
      timeAgo: 'الآن',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // إنجاز
  static void showAchievement({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.achievement,
      badge: 'إنجاز',
      duration: const Duration(seconds: 7),
      onTap: onTap,
      onAction: onAction,
    );
  }

  // منشور كوميونيتي
  static void showCommunityPost({
    required BuildContext context,
    required String userName,
    required String message,
    String? avatarUrl,
    String? badge,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: 'منشور جديد',
      message: message,
      type: NotificationType.communityPost,
      senderName: userName,
      avatarUrl: avatarUrl,
      badge: badge,
      timeAgo: 'الآن',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // مسابقة
  static void showCompetition({
    required BuildContext context,
    required String title,
    required String message,
    String? timeAgo,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.competition,
      badge: 'مسابقة',
      timeAgo: timeAgo,
      onTap: onTap,
      onAction: onAction,
    );
  }

  // واجب منزلي
  static void showHomework({
    required BuildContext context,
    required String title,
    required String message,
    String? timeAgo,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.homework,
      badge: 'واجب',
      timeAgo: timeAgo ?? 'يوم باقي',
      onTap: onTap,
      onAction: onAction,
    );
  }

  // نتيجة/درجة
  static void showGrade({
    required BuildContext context,
    required String title,
    required String message,
    String? badge,
    VoidCallback? onTap,
    VoidCallback? onAction,
  }) {
    show(
      context: context,
      title: title,
      message: message,
      type: NotificationType.grade,
      badge: badge ?? 'نتيجة',
      timeAgo: 'الآن',
      onTap: onTap,
      onAction: onAction,
    );
  }
}
