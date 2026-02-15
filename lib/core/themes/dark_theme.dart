import 'package:flutter/material.dart';

import '../core.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.darkBackground,
  brightness: Brightness.dark,
  fontFamily: AppFonts.primaryFont,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.darkPrimary,
    brightness: Brightness.dark,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkText,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: AppTextStyling.font10W400TextColor.copyWith(
      color: AppColors.darkText,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: AppColors.darkText),
  ),

  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: AppColors.darkText,
    displayColor: AppColors.darkText,
    fontFamily: AppFonts.textFont,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyling.font10W400TextColor,
      elevation: 0,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkSecondary, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkSecondary, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkError, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.darkError, width: 1.5),
    ),
    fillColor: AppColors.darkBlue,
    filled: true,
    hintStyle: AppTextStyling.font10W400TextColor.copyWith(
      color: AppColors.darkText.withValues(alpha: 0.5),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.darkBlue;
      }
      return AppColors.darkSecondary;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.darkPrimary;
      }
      return AppColors.darkSecondary;
    }),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  bottomAppBarTheme: BottomAppBarThemeData(
    color: AppColors.darkBackground,
    elevation: 0,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.darkBackground,
  ),
  dividerTheme: DividerThemeData(
    color: AppColors.darkSecondary,
    thickness: 1,
    endIndent: 10,
    indent: 10,
  ),
);
