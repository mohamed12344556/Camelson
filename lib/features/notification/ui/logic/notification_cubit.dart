import 'dart:developer';

import 'package:boraq/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial()) {
    loadNotifications();
  }

  List<NotificationModel> _notifications = [];

  // Store deleted notifications with their original index for proper restoration
  final Map<String, int> _deletedNotificationIndexes = {};

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // Load notifications
  Future<void> loadNotifications() async {
    safeEmit(NotificationLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final loadedNotifications = [
        NotificationModel(
          id: '1',
          icon: Icons.apps,
          title: 'New Category Course.!',
          subtitle: 'New the 3D Design Course is Available...',
          createdAt: DateTime.now(),
          isNew: true,
        ),
        NotificationModel(
          id: '2',
          icon: Icons.video_library,
          title: 'New Category Course.!',
          subtitle: 'New the 3D Design Course is Available...',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          isNew: true,
        ),
        NotificationModel(
          id: '3',
          icon: Icons.local_offer,
          title: "Today's Special Offers",
          subtitle: 'You Have made a Course Payment.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          isNew: false,
        ),
        NotificationModel(
          id: '4',
          icon: Icons.credit_card,
          title: 'Credit Card Connected.!',
          subtitle: 'Credit Card has been Linked.!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isNew: false,
        ),
        NotificationModel(
          id: '5',
          icon: Icons.alarm_add_sharp,
          title: 'Upcoming Payment.!',
          subtitle: 'Credit Card has been Linked.!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isNew: false,
        ),
        NotificationModel(
          id: '6',
          icon: Icons.person,
          title: 'Account Setup Successful.!',
          subtitle: 'Your Account has been Created.',
          createdAt: DateTime(2022, 11, 20),
          isNew: false,
        ),
        NotificationModel(
          id: '7',
          icon: Icons.person,
          title: 'Account Setup Successful.!',
          subtitle: 'Your Account has been Created.',
          createdAt: DateTime(2029, 11, 20),
          isNew: false,
        ),
        NotificationModel(
          id: '8',
          icon: Icons.person,
          title: 'Account Setup Successful.!',
          subtitle: 'Your Account has been Created.',
          createdAt: DateTime(1999, 11, 20),
          isNew: false,
        ),
      ];

      _notifications = loadedNotifications;
      safeEmit(NotificationLoaded(_notifications));
    } catch (e) {
      safeEmit(NotificationError('Failed to load notifications: $e'));
    }
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final notificationIndex = _notifications.indexWhere(
      (n) => n.id == notificationId,
    );

    if (notificationIndex != -1) {
      final notification = _notifications[notificationIndex];

      log(
        'Notification tapped: ${notification.title} - ${notification.subtitle}',
      );
      log('Notification ID: ${notification.id}');
      log('Created at: ${notification.createdAt}');
      log('Was new: ${notification.isNew}');
      log('---');

      // Create a new notification with updated status
      final updatedNotification = notification.copyWith(
        isRead: true,
        isNew: false,
      );

      _notifications[notificationIndex] = updatedNotification;

      safeEmit(NotificationLoaded(_notifications));
      safeEmit(NotificationMarkedAsRead(updatedNotification));
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    final unreadNotifications = _notifications.where((n) => !n.isRead).toList();

    if (unreadNotifications.isEmpty) {
      safeEmit(NotificationInfo('All notifications are already read'));
      return;
    }

    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(
        isRead: true,
        isNew: false,
      );
    }

    safeEmit(NotificationLoaded(_notifications));
    safeEmit(NotificationAllMarkedAsRead(unreadNotifications.length));
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    final notificationIndex = _notifications.indexWhere(
      (n) => n.id == notificationId,
    );

    if (notificationIndex != -1) {
      final notification = _notifications[notificationIndex];

      // Store the original index for restoration
      _deletedNotificationIndexes[notificationId] = notificationIndex;

      _notifications.removeAt(notificationIndex);

      safeEmit(NotificationLoaded(_notifications));
      safeEmit(NotificationDeleted(notification));
    }
  }

  // Restore deleted notification (for undo functionality)
  void restoreNotification(NotificationModel notification) {
    final originalIndex = _deletedNotificationIndexes[notification.id];

    if (originalIndex != null) {
      // Insert at the original position, but make sure it's within bounds
      final insertIndex = originalIndex > _notifications.length
          ? _notifications.length
          : originalIndex;

      _notifications.insert(insertIndex, notification);

      // Remove from deleted indexes map
      _deletedNotificationIndexes.remove(notification.id);
    } else {
      // Fallback: add to the end and sort by date
      _notifications.add(notification);
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    safeEmit(NotificationLoaded(_notifications));
    safeEmit(NotificationRestored(notification));
  }

  // Clear all notifications
  void clearAllNotifications() {
    final clearedNotifications = List<NotificationModel>.from(_notifications);
    _notifications.clear();
    _deletedNotificationIndexes.clear();

    safeEmit(NotificationLoaded(_notifications));
    safeEmit(NotificationAllCleared(clearedNotifications));
  }

  // Group notifications by date
  Map<String, List<NotificationModel>> getGroupedNotifications() {
    Map<String, List<NotificationModel>> grouped = {};

    for (var notification in _notifications) {
      String dateKey = _getDateKey(notification.createdAt);
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }

    return grouped;
  }

  // Get date key helper
  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(date.year, date.month, date.day);

    if (notificationDate == today) {
      return 'Today';
    } else if (notificationDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    }
  }

  // Get month name helper
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
