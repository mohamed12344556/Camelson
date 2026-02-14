// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/modern_empty_state.dart';
import '../../../../core/widgets/modern_loading_indicator.dart';
import '../../data/models/notification_model.dart';
import '../logic/notification_cubit.dart';
import '../widgets/widget_notification_card.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) {
        // Handle side effects using extension methods
        switch (state) {
          case NotificationMarkedAsRead(:final notification):
            if (notification.isRead) {
              context.showInfoSnackBar('تم وضع علامة مقروء على الإشعار');
            }
            break;
          case NotificationAllMarkedAsRead(:final count):
            context.showSuccessSnackBar(
              'تم وضع علامة مقروء على $count إشعارات',
            );
            break;
          case NotificationDeleted(:final notification):
            context.showActionSnackBar(
              message: 'تم حذف الإشعار',
              actionLabel: 'تراجع',
              onActionPressed: () {
                context.read<NotificationCubit>().restoreNotification(
                  notification,
                );
              },
              backgroundColor: const Color(0xFFFF6B6B),
              icon: Icons.delete_outline,
            );
            break;
          case NotificationRestored(:final notification):
            context.showSuccessSnackBar('تم استعادة الإشعار بنجاح');
            break;
          case NotificationAllCleared():
            context.showSuccessSnackBar('تم مسح جميع الإشعارات بنجاح');
            break;
          case NotificationInfo(:final message):
            context.showInfoSnackBar(message);
            break;
          case NotificationError(:final message):
            context.showErrorSnackBar(message);
            break;
          default:
            break;
        }
      },
      builder: (context, state) {
        final cubit = context.read<NotificationCubit>();

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(
            onBackPressed: () {
              context.setNavBarVisible(true);
              Navigator.pop(context);
            },
            titleWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الإشعارات',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (cubit.unreadCount > 0)
                  Text(
                    '${cubit.unreadCount} غير مقروء',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),

            actions: [
              if (cubit.notifications.isNotEmpty &&
                  state is! NotificationLoading) ...[
                // Mark all as read button
                if (cubit.unreadCount > 0)
                  IconButton(
                    icon: const Icon(Icons.mark_email_read, color: Colors.blue),
                    onPressed: () => _markAllAsRead(context),
                    tooltip: 'وضع علامة مقروء على الكل',
                  ),
                // Clear all button
                IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.red),
                  onPressed: () => _clearAllNotifications(context),
                  tooltip: 'مسح جميع الإشعارات',
                ),
              ],
            ],
          ),
          body: _buildBody(context, state, cubit),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationState state,
    NotificationCubit cubit,
  ) {
    switch (state) {
      case NotificationLoading():
        return const ModernLoadingIndicator(message: 'جاري تحميل الإشعارات...');
      case NotificationInitial():
        return const ModernLoadingIndicator(message: 'جاري التهيئة...');
      default:
        if (cubit.notifications.isEmpty) {
          return const ModernEmptyState.notifications();
        }
        return RefreshIndicator(
          onRefresh: () => cubit.loadNotifications(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: _buildNotificationsList(context, cubit),
          ),
        );
    }
  }

  List<Widget> _buildNotificationsList(
    BuildContext context,
    NotificationCubit cubit,
  ) {
    List<Widget> widgets = [];
    final groupedNotifications = cubit.getGroupedNotifications();

    for (var entry in groupedNotifications.entries) {
      // Add date header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            entry.key,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      );

      // Add notifications for this date
      for (var notification in entry.value) {
        widgets.add(
          NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(context, notification, cubit),
            onDelete: () =>
                _handleNotificationDelete(context, notification, cubit),
          ),
        );
        widgets.add(const SizedBox(height: 12));
      }

      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  // Handle notification tap with enhanced feedback
  void _handleNotificationTap(
    BuildContext context,
    NotificationModel notification,
    NotificationCubit cubit,
  ) {
    if (!notification.isRead) {
      cubit.markAsRead(notification.id);
      // Show subtle feedback for marking as read
      Future.delayed(const Duration(milliseconds: 300), () {
        if (context.mounted) {
          context.showInfoSnackBar('تم وضع علامة مقروء على الإشعار');
        }
      });
    }
  }

  // Handle notification deletion with confirmation using extension
  void _handleNotificationDelete(
    BuildContext context,
    NotificationModel notification,
    NotificationCubit cubit,
  ) async {
    final result = await context.showDeleteConfirmationDialog(
      title: 'حذف الإشعار',
      message: 'هل أنت متأكد من حذف هذا الإشعار؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
    );

    if (result == true) {
      cubit.deleteNotification(notification.id);
    }
  }

  // Mark all as read with enhanced confirmation and feedback
  Future<void> _markAllAsRead(BuildContext context) async {
    final cubit = context.read<NotificationCubit>();
    final unreadCount = cubit.unreadCount;

    if (unreadCount == 0) {
      context.showInfoSnackBar('جميع الإشعارات مقروءة بالفعل');
      return;
    }

    final result = await context.showConfirmationDialog(
      title: 'وضع علامة مقروء على الكل',
      message:
          'هل تريد وضع علامة مقروء على جميع الإشعارات ($unreadCount إشعار)؟',
      confirmText: 'وضع علامة مقروء',
      cancelText: 'إلغاء',
      icon: Icons.mark_email_read,
      iconGradient: const [Colors.blue, Colors.lightBlue],
    );

    if (result == true) {
      // Show loading feedback
      context.showInfoSnackBar('جاري وضع علامة مقروء على الإشعارات...');

      // Simulate processing time for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      cubit.markAllAsRead();
    }
  }

  // Clear all notifications with enhanced confirmation
  Future<void> _clearAllNotifications(BuildContext context) async {
    final cubit = context.read<NotificationCubit>();
    final notificationCount = cubit.notifications.length;

    if (notificationCount == 0) {
      context.showInfoSnackBar('لا توجد إشعارات لحذفها');
      return;
    }

    final result = await context.showDeleteConfirmationDialog(
      title: 'مسح جميع الإشعارات',
      message:
          'هل أنت متأكد من حذف جميع الإشعارات ($notificationCount إشعار)؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'مسح الكل',
      cancelText: 'إلغاء',
    );

    if (result == true) {
      // Show warning before clearing
      context.showWarningSnackBar('جاري مسح جميع الإشعارات...');

      // Add delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      cubit.clearAllNotifications();
    }
  }
}
