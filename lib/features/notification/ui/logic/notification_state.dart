part of 'notification_cubit.dart';

@immutable
sealed class NotificationState {}

// Initial state
final class NotificationInitial extends NotificationState {}

// Loading state
final class NotificationLoading extends NotificationState {}

// Success states
final class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;

  NotificationLoaded(this.notifications);
}

final class NotificationMarkedAsRead extends NotificationState {
  final NotificationModel notification;

  NotificationMarkedAsRead(this.notification);
}

final class NotificationAllMarkedAsRead extends NotificationState {
  final int count;

  NotificationAllMarkedAsRead(this.count);
}

final class NotificationDeleted extends NotificationState {
  final NotificationModel notification;

  NotificationDeleted(this.notification);
}

final class NotificationRestored extends NotificationState {
  final NotificationModel notification;

  NotificationRestored(this.notification);
}

final class NotificationAllCleared extends NotificationState {
  final List<NotificationModel> clearedNotifications;

  NotificationAllCleared(this.clearedNotifications);
}

// Info state
final class NotificationInfo extends NotificationState {
  final String message;

  NotificationInfo(this.message);
}

// Error state
final class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}
