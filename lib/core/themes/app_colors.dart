import 'package:flutter/material.dart';

class AppColors {
  //Private constructor to prevent instantiation
  AppColors._();
  // Light Mood - Simplify Theme (Golden/Yellow)
  static const Color primary = Color(0xFFF5B921); // Golden Yellow
  static const Color secondary = Color(0xFFFFF9E6); // Light Cream
  static const Color background = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2C2C2C); // Dark Gray Text
  static const Color error = Color(0xFFB00020);
  static const Color lightSecondary = Color(0xFFF5F5F5);
  static const Color lightBackground = Color(0xFFFFFBF0); // Light Yellow Background
  static const Color lightWhite = Color(0xFFFFFDF7);
  static const Color lightBlue = Color(0xFFF5B921); // Same as primary for compatibility
  static const Color accent = Color(0xFFFFD700); // Bright Gold
  static const Color darkBlue = Color(0xFF1A1A1A); // Almost Black
  // Dark Mood
  static const Color darkSecondary = Color(0xFF4B4B4B);
  static const Color darkBackground = Color(0xFF1F1F1F);
  static const Color darkText = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFB00020);
  static const Color darkPrimary = Color(0xFFFFD700); // Bright Gold for dark mode
}
