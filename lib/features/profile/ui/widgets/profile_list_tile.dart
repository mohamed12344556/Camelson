import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/core.dart';
import '../../../auth/ui/logic/auth_cubit.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? page;
  final String? trailing;
  final VoidCallback? onLanguageChanged;
  final bool isLogout;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    this.page,
    this.trailing,
    this.onLanguageChanged,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    // Special styling for logout
    final isLogoutTile = isLogout;
    final iconColor = isLogoutTile ? Colors.red[600] : Colors.grey[600];
    final textColor = isLogoutTile ? Colors.red[600] : Colors.black;

    return ListTile(
      leading: Icon(icon, size: 24.sp, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                color: const Color(0xFF0961F5),
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          SizedBox(width: 5.w),
          if (!isLogoutTile)
            Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.black),
        ],
      ),
      onTap: () async {
        if (isLogoutTile) {
          // Handle logout
          _showLogoutDialog(context);
        } else if (page != null) {
          // Navigate to page
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
          // If returning from language settings and callback is provided
          if (title == 'Language' && onLanguageChanged != null) {
            onLanguageChanged!();
          }
        }
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    // Get AuthCubit from GetIt (service locator)
    final authCubit = sl<AuthCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocConsumer<AuthCubit, AuthState>(
        bloc: authCubit, // Use the cubit from GetIt
        listener: (_, state) {
          if (state is AuthLoggedOut) {
            // Close dialog
            Navigator.pop(dialogContext);
            // Navigate to login screen and remove all previous routes
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.loginView,
              (route) => false,
            );
          } else if (state is AuthError) {
            // Close dialog
            Navigator.pop(dialogContext);
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error.errorMessage?.message ?? 'Logout failed',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (_, state) {
          final isLoading = state is AuthLoading;

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16.sp),
            ),
            actions: [
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              if (isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    authCubit.logout();
                  },
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
