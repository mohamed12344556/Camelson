import 'package:flutter/material.dart';
import '../core.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool isTitleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final bool useCustomBackButton;
  final VoidCallback? onBackPressed;
  final bool centerTitle;
  final TextStyle? titleStyle;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.isTitleWidget = false,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
    this.useCustomBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultBackgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.background;
    final effectiveBackgroundColor = backgroundColor ?? defaultBackgroundColor;

    return AppBar(
      title: _buildTitle(context),
      actions: actions,
      leading:
          leading ??
          _buildLeading(context, effectiveBackgroundColor, isDarkMode),
      backgroundColor: effectiveBackgroundColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
    );
  }

  Widget? _buildTitle(BuildContext context) {
    // إذا كان titleWidget موجود، استخدمه
    if (titleWidget != null) {
      return titleWidget;
    }

    // إذا كان title موجود، استخدمه
    if (title != null) {
      return Text(
        title!,
        style: titleStyle ?? Theme.of(context).appBarTheme.titleTextStyle,
      );
    }

    // إذا لم يكن هناك عنوان
    return null;
  }

  Widget? _buildLeading(BuildContext context, Color bgColor, bool isDarkMode) {
    // إذا لم يكن هناك route للعودة إليه، لا تظهر الزر
    if (!Navigator.of(context).canPop()) {
      return null;
    }

    if (useCustomBackButton) {
      return _buildCustomBackButton(context, isDarkMode);
    } else {
      return BackButton(
        color: (bgColor == AppColors.background) ? AppColors.text : AppColors.background,
        onPressed: onBackPressed,
      );
    }
  }

  Widget _buildCustomBackButton(BuildContext context, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkSecondary : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? AppColors.darkText : AppColors.text).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: isDarkMode ? AppColors.darkText : AppColors.text,
          size: 18,
        ),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        splashRadius: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
