import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../profile/ui/logic/profle/profile_cubit.dart';
import '../../../profile/ui/logic/profle/profile_state.dart';
import 'build_greeting_mood_and_user_name.dart';
import 'custom_circle_avatar.dart';

class BuildHeaderNavBar extends StatelessWidget {
  const BuildHeaderNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    String notificationCount = '100';

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final isLoading =
            state.status == ProfileStatus.loading && state.userData == null;
        final userName = state.userData?.name;
        log('userName: ${state.userData}');
        return Row(
          children: [
            const CustomCircleAvatar(),
            SizedBox(width: 10.w),
            BuildGreetingMoodAndUserName(
              userName: userName,
              isLoading: isLoading,
            ),
            const Spacer(),
            _buildNotesButton(),
            SizedBox(width: 10.w),
            _buildNotificationButton(context, notificationCount),
          ],
        );
      },
    );
  }

  Widget _buildNotesButton() {
    return CustomCircleAvatar(
      isHasImage: false,
      onTap: () => log('Notes'),
      backgroundColor: AppColors.primary.withValues(alpha: 0.8),
      child: Image.asset('assets/images/notes.png', width: 35.w, height: 35.h),
    );
  }

  Widget _buildNotificationButton(
    BuildContext context,
    String notificationCount,
  ) {
    return CustomCircleAvatar(
      isHasImage: false,
      onTap: () => _handleNotificationTap(context),
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
          color: AppColors.background,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xffFF6B2C),
      child: Icon(
        Icons.notifications_none_sharp,
        color: AppColors.background,
        size: 35.sp,
      ),
    );
  }

  String _getDisplayCount(String count) {
    final intCount = int.tryParse(count) ?? 0;
    return intCount >= 100 ? '99+' : count;
  }

  void _handleNotificationTap(BuildContext context) {
    try {
      context.pushNamed(AppRoutes.notificationsView);
      log('Navigating to notifications');
    } catch (e) {
      log('Error navigating to notifications: $e');
      context.showErrorSnackBar('حدث خطأ في فتح الإشعارات');
    }
  }
}
