import 'package:flutter/material.dart';
import 'app_theme.dart';

class DarkTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppTheme.primaryColor,
      brightness: Brightness.dark,
    ),
    
    // App bar theme
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppTheme.surfaceDark,
      foregroundColor: AppTheme.textPrimaryDark,
      iconTheme: IconThemeData(color: AppTheme.textPrimaryDark),
      titleTextStyle: TextStyle(
        color: AppTheme.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E1E1E),
    ),
    
    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined button theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppTheme.primaryColor),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
        color: AppTheme.textSecondaryDark,
      ),
    ),
    
    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryDark,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimaryDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryDark,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppTheme.textPrimaryDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppTheme.textPrimaryDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppTheme.textSecondaryDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryDark,
      ),
    ),
    
    // Scaffold background
    scaffoldBackgroundColor: AppTheme.backgroundDark,
    
    // Divider theme
    dividerTheme: const DividerThemeData(
      color: AppTheme.textSecondaryDark,
      thickness: 1,
      space: 1,
    ),
    
    // Icon theme
    iconTheme: const IconThemeData(
      color: AppTheme.textPrimaryDark,
    ),
    
    // Bottom navigation bar theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppTheme.surfaceDark,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2C2C2C),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: const TextStyle(
        color: AppTheme.textPrimaryDark,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    
    // Dialog theme
    dialogTheme: DialogTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 8,
    ),
    
    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
