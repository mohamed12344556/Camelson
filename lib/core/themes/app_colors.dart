import 'package:flutter/material.dart';

class AppColors {
  //Private constructor to prevent instantiation
  AppColors._();

  // ============================================
  // Light Theme Colors (Golden/Yellow Theme)
  // ============================================
  static const Color primary = Color(0xFFF5B921); // Golden Yellow - Primary brand color
  static const Color secondary = Color(0xFFFFF9E6); // Light Cream - Secondary elements
  static const Color background = Color(0xFFFFFFFF); // Pure White - Main background
  static const Color text = Color(0xFF2C2C2C); // Dark Gray - Primary text
  static const Color error = Color(0xFFB00020); // Red - Error states

  // Light Theme - Additional Colors
  static const Color lightSecondary = Color(0xFFF5F5F5); // Light Gray - Borders/Dividers
  static const Color lightBackground = Color(0xFFFFFBF0); // Light Yellow - Alternative background
  static const Color lightWhite = Color(0xFFFFFDF7); // Off White - Card backgrounds
  static const Color accent = Color(0xFFFFD700); // Bright Gold - Accents & highlights

  // ============================================
  // Dark Theme Colors
  // ============================================
  static const Color darkPrimary = Color(0xFFFFD700); // Bright Gold - Primary in dark mode
  static const Color darkSecondary = Color(0xFF4B4B4B); // Medium Gray - Secondary elements
  static const Color darkBackground = Color(0xFF1F1F1F); // Dark Gray - Main background
  static const Color darkText = Color(0xFFFFFFFF); // Pure White - Text in dark mode
  static const Color darkError = Color(0xFFCF6679); // Light Red - Error in dark mode
  static const Color darkBlue = Color(0xFF1A1A1A); // Almost Black - Deep backgrounds

  // Deprecated - kept for backwards compatibility
  @Deprecated('Use primary instead')
  static const Color lightBlue = Color(0xFFF5B921);
}
