import 'dart:developer';

// Navigation extensions moved to core/utils/extensions.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../notes/ui/logic/notes_cubit.dart';
import '../../../profile/ui/logic/profle/profile_cubit.dart';
import '../../../profile/ui/logic/profle/profile_state.dart';
import 'build_greeting_mood_and_user_name.dart';
import 'custom_circle_avatar.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarWidget({super.key});

  @override
  Size get preferredSize => Size.fromHeight(80.h);

  @override
  Widget build(BuildContext context) {
    String notificationCount = '100';

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 60.h,
      title: Row(
        children: [
          const CustomCircleAvatar(),
          SizedBox(width: 10.w),
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final isLoading =
                  state.status == ProfileStatus.loading &&
                  state.userData == null;
              final userName = state.userData?.name;
              log('userName: ${state.userData}');
              return BuildGreetingMoodAndUserName(
                userName: userName,
                isLoading: isLoading,
              );
            },
          ),
          const Spacer(),
          _buildNotesButton(context),
          SizedBox(width: 10.w),
          _buildNotificationButton(context, notificationCount),
        ],
      ),
      titleSpacing: 16.w,
    );
  }

  Widget _buildNotesButton(BuildContext context) {
    return CustomCircleAvatar(
      isHasImage: false,
      onTap: () {
        _handleNotesTap(context);
        context.setNavBarVisible(false);
      },
      backgroundColor: AppColors.lightBlue.withValues(alpha: 0.8),
      child: Image.asset('assets/images/notes.png', width: 35.w, height: 35.h),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    String notificationCount,
  ) {
    return CustomCircleAvatar(
      isHasImage: false,
      onTap: () {
        _handleNotificationTap(context);
        context.setNavBarVisible(false);
      },
      backgroundColor: AppColors.primary,
      child: _buildNotificationBadge(notificationCount),
    );
  }

  Widget _buildNotificationBadge(String notificationCount) {
    final hasNotifications =
        notificationCount != "0" && notificationCount.isNotEmpty;
    final displayCount = _getDisplayCount(notificationCount);

    return Badge(
      isLabelVisible: hasNotifications,
      offset: Offset(3.w, -1.h),
      label: Text(
        displayCount,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xffFF6B2C),
      child: Icon(
        Icons.notifications_none_sharp,
        color: Colors.white,
        size: 35.sp,
      ),
    );
  }

  String _getDisplayCount(String count) {
    final intCount = int.tryParse(count) ?? 0;
    return intCount >= 100 ? '99+' : count;
  }

  // الحل الأساسي: تحديد الشاشة المناسبة حسب وجود الـ notes
  void _handleNotesTap(BuildContext context) {
    try {
      // التحقق من وجود notes أولاً
      final notesCubit = sl<NotesCubit>();

      if (notesCubit.hasNotes()) {
        // إذا كان فيه notes، اروح على شاشة الـ notes
        context.pushNamed(AppRoutes.allNotes);
      } else {
        // إذا مافيش notes، اروح على الشاشة الفاضية
        context.pushNamed(AppRoutes.emptyNotes);
      }

      log('Navigating to notes');
    } catch (e) {
      log('Error navigating to notes: $e');
      // في حالة حدوث خطأ، اروح على الشاشة الفاضية كـ fallback
      context.pushNamed(AppRoutes.emptyNotes);
    }
  }

  void _handleNotificationTap(BuildContext context) {
    try {
      context.pushNamed(AppRoutes.notificationsView);
      log('Navigating to notifications');
    } catch (e) {
      log('Error navigating to notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ في فتح الإشعارات'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
