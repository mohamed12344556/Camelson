import 'package:flutter/material.dart';

import '../core.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  brightness: Brightness.light,
  fontFamily: AppFonts.primaryFont,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    surface: AppColors.background,
    onSurface: AppColors.text,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyling.font10W400TextColor.copyWith(
      color: AppColors.text,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.text),
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: AppColors.text,
    displayColor: AppColors.text,
    fontFamily: AppFonts.textFont,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyling.font10W400TextColor,
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.lightSecondary, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.lightSecondary, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
    fillColor: AppColors.lightWhite,
    filled: true,
    hintStyle: AppTextStyling.font10W400TextColor.copyWith(
      color: AppColors.text.withValues(alpha: 0.5),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.background;
      }
      return AppColors.lightSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.lightSecondary;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: AppColors.background,
    elevation: 0,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.background,
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.lightSecondary,
    thickness: 1,
    endIndent: 10,
    indent: 10,
  ),
);
