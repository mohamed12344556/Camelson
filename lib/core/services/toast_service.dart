import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../themes/app_colors.dart';

/// Custom toast service using toastification package.
/// Provides themed toast notifications that match the app's design system.
class ToastService {
  ToastService._();

  static const Duration _defaultDuration = Duration(seconds: 4);
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 6);

  /// Shows a success toast notification
  static ToastificationItem showSuccess({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return _showToast(
      context: context,
      type: ToastificationType.success,
      title: title ?? 'Success',
      message: message,
      duration: duration ?? _defaultDuration,
      primaryColor: _getSuccessColor(context),
      icon: Icons.check_circle_rounded,
      onTap: onTap,
    );
  }

  /// Shows an error toast notification
  static ToastificationItem showError({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return _showToast(
      context: context,
      type: ToastificationType.error,
      title: title ?? 'Error',
      message: message,
      duration: duration ?? _defaultDuration,
      primaryColor: _getErrorColor(context),
      icon: Icons.error_rounded,
      onTap: onTap,
    );
  }

  /// Shows an info toast notification
  static ToastificationItem showInfo({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return _showToast(
      context: context,
      type: ToastificationType.info,
      title: title ?? 'Info',
      message: message,
      duration: duration ?? _defaultDuration,
      primaryColor: _getInfoColor(context),
      icon: Icons.notifications_rounded,
      onTap: onTap,
    );
  }

  /// Shows a warning toast notification
  static ToastificationItem showWarning({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return _showToast(
      context: context,
      type: ToastificationType.warning,
      title: title ?? 'Warning',
      message: message,
      duration: duration ?? _defaultDuration,
      primaryColor: _getWarningColor(context),
      icon: Icons.warning_rounded,
      onTap: onTap,
    );
  }

  /// Shows a notification toast (red background like push notifications)
  static ToastificationItem showNotification({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return _showToast(
      context: context,
      type: ToastificationType.info,
      title: title ?? 'Notification',
      message: message,
      duration: duration ?? _defaultDuration,
      primaryColor: const Color(0xFFE53935), // Red like the image
      icon: Icons.check_circle_rounded,
      onTap: onTap,
    );
  }

  /// Shows a custom toast with full control over appearance
  static ToastificationItem showCustom({
    required BuildContext context,
    required String message,
    String? title,
    Duration? duration,
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color:
                    foregroundColor ??
                    (isDark ? Colors.white : AppColors.darkBlue),
              ),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: foregroundColor ?? (isDark ? Colors.white70 : AppColors.text),
        ),
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration ?? _defaultDuration,
      primaryColor: backgroundColor ?? AppColors.primary,
      backgroundColor:
          backgroundColor ?? (isDark ? AppColors.darkBackground : Colors.white),
      foregroundColor: foregroundColor,
      icon: icon != null
          ? Icon(icon, color: backgroundColor ?? AppColors.primary)
          : null,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      callbacks: ToastificationCallbacks(
        onTap: onTap != null ? (_) => onTap() : null,
      ),
    );
  }

  /// Shows a loading toast (doesn't auto-dismiss)
  static ToastificationItem showLoading({
    required BuildContext context,
    required String message,
    String? title,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isDark ? Colors.white : AppColors.darkBlue,
              ),
            )
          : null,
      description: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white70 : AppColors.text,
        ),
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: null,
      primaryColor: AppColors.primary,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      icon: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: false,
      closeButtonShowType: CloseButtonShowType.none,
      closeOnClick: false,
      pauseOnHover: false,
      dragToClose: false,
    );
  }

  /// Dismisses a specific toast
  static void dismiss(ToastificationItem item) {
    toastification.dismiss(item);
  }

  /// Dismisses all toasts
  static void dismissAll() {
    toastification.dismissAll();
  }

  /// Internal method to show toast with consistent styling
  static ToastificationItem _showToast({
    required BuildContext context,
    required ToastificationType type,
    required String title,
    required String message,
    required Duration duration,
    required Color primaryColor,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.fillColored,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
      description: Text(
        message,
        style: TextStyle(
          fontSize: 13,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: duration,
      primaryColor: primaryColor,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      showProgressBar: true,
      progressBarTheme: ProgressIndicatorThemeData(
        color: Colors.white.withValues(alpha: 0.7),
        linearTrackColor: Colors.white.withValues(alpha: 0.2),
      ),
      closeButtonShowType: CloseButtonShowType.always,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      callbacks: ToastificationCallbacks(
        onTap: onTap != null ? (_) => onTap() : null,
      ),
    );
  }

  // Color helpers based on theme
  static Color _getSuccessColor(BuildContext context) {
    return const Color(0xFF22C55E);
  }

  static Color _getErrorColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkError : AppColors.error;
  }

  static Color _getInfoColor(BuildContext context) {
    return AppColors.primary;
  }

  static Color _getWarningColor(BuildContext context) {
    return const Color(0xFFF59E0B);
  }
}
