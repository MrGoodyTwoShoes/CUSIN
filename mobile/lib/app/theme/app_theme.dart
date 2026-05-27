import 'package:flutter/material.dart';
import 'dark_theme.dart';
import 'light_theme.dart';

class AppTheme {
  AppTheme._();
  
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;
  
  // Custom colors that work in both themes
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Incident severity colors
  static const Color severityLow = Color(0xFF4CAF50);
  static const Color severityMedium = Color(0xFFFF9800);
  static const Color severityHigh = Color(0xFFFF5722);
  static const Color severityCritical = Color(0xFFF44336);
  
  // Trust score colors
  static const Color trustLow = Color(0xFFF44336);
  static const Color trustMedium = Color(0xFFFF9800);
  static const Color trustHigh = Color(0xFF4CAF50);
  
  // Background colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF000000);
  
  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
}
