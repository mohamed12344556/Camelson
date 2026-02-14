import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../features/home/data/services/navigation_manager.dart';
import '../services/toast_service.dart';
import '../widgets/modern_dialogs.dart';
import 'number_utils.dart';

extension BuildContextExtensions on BuildContext {
  // Use singleton instance directly
  static final NavigationManager _navManager = NavigationManager();
  NavigationManager get _nav => _navManager;

  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }

  // Add this getter for language
  bool get isArabic {
    return Localizations.localeOf(this).languageCode == 'ar';
  }

  // Theme extensions
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ===== NEW Tab-Aware Navigation Methods =====

  /// Navigate to specific route in current tab
  void navigateTo(String route, {Object? arguments}) {
    _nav.navigateInCurrentTab(route, arguments: arguments);
  }

  /// Navigate to specific route in specific tab
  void navigateToTab(int tabIndex, String route, {Object? arguments}) {
    _nav.navigateToRoute(tabIndex, route, arguments: arguments);
  }

  /// Navigate to route in home tab (tab 0)
  void navigateToHome(String route, {Object? arguments}) {
    _nav.navigateInHomeTab(route, arguments: arguments);
  }

  /// Switch to specific tab
  void switchTab(int tabIndex) {
    _nav.switchToTab(tabIndex);
  }

  /// Go back in current tab
  void goBack() {
    _nav.goBackInTab(_nav.currentTabIndex);
  }

  /// Reset current tab to root
  void resetCurrentTab() {
    _nav.resetTabToRoot(_nav.currentTabIndex);
  }

  /// Reset specific tab to root
  void resetTab(int tabIndex) {
    _nav.resetTabToRoot(tabIndex);
  }

  /// Check if current tab can go back
  bool canGoBack() {
    return _nav.canGoBack(_nav.currentTabIndex);
  }

  /// Get current route in current tab
  String getCurrentRoute() {
    return _nav.getCurrentRoute(_nav.currentTabIndex);
  }

  /// Manually show/hide navigation bar
  void setNavBarVisible(bool visible) {
    _nav.setNavBarVisibility(visible);
  }

  /// Handle bottom sheet state
  void setBottomSheetOpen(bool isOpen) {
    _nav.setBottomSheetState(isOpen);
  }

  // ===== Legacy Navigation Methods (for backward compatibility) =====
  // These use standard Navigator and are NOT tab-aware

  @Deprecated('Use navigateTo() instead for tab-aware navigation')
  Future<dynamic> navigateToNamed(String routeName) async {
    return Navigator.pushNamed(this, routeName);
  }

  @Deprecated('Use navigateTo() instead for tab-aware navigation')
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  @Deprecated('Use navigateTo() instead for tab-aware navigation')
  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  @Deprecated('Use navigateTo() instead for tab-aware navigation')
  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    return Navigator.of(
      this,
    ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  @Deprecated('Use goBack() instead for tab-aware navigation')
  void pop() => Navigator.of(this).pop();

  // Modern Dialog methods using ModernDialogs
  Future<bool?> showConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    List<Color>? iconGradient,
    Color? confirmColor,
    bool barrierDismissible = false,
  }) {
    return ModernDialogs.showConfirmationDialog(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      icon: icon,
      iconGradient: iconGradient,
      confirmColor: confirmColor,
      barrierDismissible: barrierDismissible,
    );
  }

  Future<bool?> showDeleteConfirmationDialog({
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
    bool barrierDismissible = false,
  }) {
    return ModernDialogs.showDeleteConfirmationDialog(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      barrierDismissible: barrierDismissible,
    );
  }

  Future<void> showSuccessDialog({
    required String title,
    required String message,
    String buttonText = 'Great!',
    VoidCallback? onPressed,
  }) {
    return ModernDialogs.showSuccessDialog(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  Future<bool?> showExitConfirmationDialog({
    String title = 'Exit App',
    String message = 'Do you want to exit the app?',
    String confirmText = 'Exit',
    String cancelText = 'Cancel',
    bool barrierDismissible = false,
  }) {
    return ModernDialogs.showExitConfirmationDialog(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      barrierDismissible: barrierDismissible,
    );
  }

  Future<void> showErrorDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return ModernDialogs.showErrorDialog(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  Future<void> showModernLoadingDialog({String? message}) {
    return ModernDialogs.showLoadingDialog(context: this, message: message);
  }

  void hideLoadingDialog() {
    Navigator.of(this).pop();
  }

  // Legacy dialog method (kept for backward compatibility)
  Future<void> showSnackBarAsDialog({
    required String message,
    required bool isError,
    required void Function()? onPressed,
  }) async {
    if (isError) {
      return showErrorDialog(
        title: 'Error',
        message: message,
        buttonText: 'Got it',
        onPressed: onPressed,
      );
    } else {
      return showSuccessDialog(
        title: 'Success',
        message: message,
        buttonText: 'Got it',
        onPressed: onPressed,
      );
    }
  }

  // Enhanced SnackBar methods using AwesomeSnackbarContent
  void showErrorSnackBar(String message, {String title = 'Error'}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.failure,
          ),
        ),
      );
  }

  void showSuccessSnackBar(String message, {String title = 'Success'}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.success,
          ),
        ),
      );
  }

  void showInfoSnackBar(String message, {String title = 'Info'}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.help,
          ),
        ),
      );
  }

  void showWarningSnackBar(String message, {String title = 'Warning'}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.warning,
          ),
        ),
      );
  }

  void showSnackBar(String message, {String title = 'Notice'}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: title,
            message: message,
            contentType: ContentType.help,
          ),
        ),
      );
  }

  // ===== Toast Notification Methods (using toastification) =====

  /// Shows a success toast notification at the top of the screen
  ToastificationItem showSuccessToast(
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return ToastService.showSuccess(
      context: this,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows an error toast notification at the top of the screen
  ToastificationItem showErrorToast(
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return ToastService.showError(
      context: this,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows an info toast notification at the top of the screen
  ToastificationItem showInfoToast(
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return ToastService.showInfo(
      context: this,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows a warning toast notification at the top of the screen
  ToastificationItem showWarningToast(
    String message, {
    String? title,
    Duration? duration,
    VoidCallback? onTap,
  }) {
    return ToastService.showWarning(
      context: this,
      message: message,
      title: title,
      duration: duration,
      onTap: onTap,
    );
  }

  /// Shows a loading toast (doesn't auto-dismiss, must be manually dismissed)
  ToastificationItem showLoadingToast(String message, {String? title}) {
    return ToastService.showLoading(
      context: this,
      message: message,
      title: title,
    );
  }

  /// Shows a custom toast with full control over appearance
  ToastificationItem showCustomToast(
    String message, {
    String? title,
    Duration? duration,
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return ToastService.showCustom(
      context: this,
      message: message,
      title: title,
      duration: duration,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      icon: icon,
      onTap: onTap,
    );
  }

  /// Dismisses all active toasts
  void dismissAllToasts() {
    ToastService.dismissAll();
  }

  // Custom SnackBar with action (kept with original style for action support)
  void showActionSnackBar({
    required String message,
    required String actionLabel,
    required VoidCallback onActionPressed,
    Color? backgroundColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? const Color(0xFF4A90E2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          elevation: 6,
          action: SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            onPressed: onActionPressed,
          ),
        ),
      );
  }

  /// Enhanced bottom sheet with nav bar management
  Future<T?> showCustomBottomSheet<T>({
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    // Hide nav bar when bottom sheet opens
    setBottomSheetOpen(true);

    return showModalBottomSheet<T>(
      context: this,
      builder: builder,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor,
    ).then((result) {
      // Show nav bar when bottom sheet closes
      setBottomSheetOpen(false);
      return result;
    });
  }
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}

extension SafeEmitOnCubit<T> on Cubit<T> {
  void safeEmit(T state) {
    if (!isClosed) emit(state);
  }
}

extension SafeEmitOnBloc<Event, State> on Bloc<Event, State> {
  void safeEmit(State state) {
    if (!isClosed) emit(state);
  }
}

/// Helper class for common navigation patterns
class NavigationHelper {
  // Use singleton instance directly
  static final NavigationManager _nav = NavigationManager();

  /// Quick navigation to common routes
  static void goToCategories() {
    _nav.navigateInHomeTab('/categories');
  }

  static void goToCourses() {
    _nav.navigateInHomeTab('/courses');
  }

  static void goToNotifications() {
    _nav.navigateInHomeTab('/notifications');
  }

  static void goToProfile() {
    _nav.switchToTab(4); // Assuming profile is tab 4
  }

  static void goToHome() {
    _nav.switchToTab(0);
  }

  static void goToRank() {
    _nav.switchToTab(1);
  }

  static void goToPlan() {
    _nav.switchToTab(2);
  }

  static void goToCommunity() {
    _nav.switchToTab(3);
  }

  /// Reset all tabs to their root pages
  static void resetAllTabs() {
    _nav.resetAllTabs();
  }

  /// Check if any tab has navigation stack
  static bool hasNavigationStack() {
    for (int i = 0; i < 5; i++) {
      if (_nav.canGoBack(i)) {
        return true;
      }
    }
    return false;
  }

  /// Handle system back press
  static Future<bool> handleBackPress() {
    return _nav.handleBackPress();
  }

  /// Debug current navigation state
  static void debugState() {
    _nav.debugPrintState();
  }
}

/// Mixin for easy navigation in StatefulWidget
mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  NavigationManager get nav => NavigationManager();

  void navigateTo(String route, {Object? arguments}) {
    context.navigateTo(route, arguments: arguments);
  }

  void switchTab(int tabIndex) {
    context.switchTab(tabIndex);
  }

  void goBack() {
    context.goBack();
  }

  bool canGoBack() {
    return context.canGoBack();
  }

  String getCurrentRoute() {
    return context.getCurrentRoute();
  }
}

/// Number Extensions for Arabic localization
extension NumberLocalization on num {
  /// Convert number to Arabic digits
  String toArabic() => NumberUtils.toArabicDigits(toString());

  /// Format as price with currency
  String toPrice({
    String currency = '\$',
    int decimals = 2,
    bool isArabic = false,
  }) {
    return NumberUtils.formatPrice(
      toDouble(),
      currency: currency,
      decimalPlaces: decimals,
      isArabic: isArabic,
    );
  }

  /// Format as percentage
  String toPercentage({int decimals = 0, bool isArabic = false}) {
    return NumberUtils.formatPercentage(
      toDouble(),
      decimalPlaces: decimals,
      isArabic: isArabic,
    );
  }

  /// Format with thousand separators
  String toFormatted({bool isArabic = false}) {
    return NumberUtils.formatWithSeparator(toInt(), isArabic: isArabic);
  }
}

extension StringNumberConversion on String {
  /// Convert Arabic/Hindi digits to English
  String normalizeDigits() => NumberUtils.normalizeDigits(this);

  /// Parse to double safely
  double? toDoubleSafe() => NumberUtils.parseDouble(this);

  /// Parse to int safely
  int? toIntSafe() => NumberUtils.parseInt(this);
}
