import 'dart:math' as math;
import 'package:flutter/material.dart';

extension StringExtensions on String {
  /// Check if string is empty or only whitespace
  bool get isBlank => trim().isEmpty;
  
  /// Check if string is not empty
  bool get isNotBlank => trim().isNotEmpty;
  
  /// Capitalize first letter
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  
  /// Capitalize each word
  String get titleCase => split(' ')
      .map((word) => word.capitalize)
      .join(' ');
  
  /// Truncate with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
  
  /// Remove all whitespace
  String get removeAllWhitespace => replaceAll(RegExp(r'\s'), '');
  
  /// Check if string is a valid email
  bool get isEmail => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  
  /// Check if string is a valid phone number (basic)
  bool get isPhone => RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(this);
}

extension IntExtensions on int {
  /// Convert to duration in seconds
  Duration get seconds => Duration(seconds: this);
  
  /// Convert to duration in minutes
  Duration get minutes => Duration(minutes: this);
  
  /// Convert to duration in hours
  Duration get hours => Duration(hours: this);
  
  /// Convert to duration in days
  Duration get days => Duration(days: this);
}

extension DoubleExtensions on double {
  /// Round to specified decimal places
  double roundTo(int decimals) {
    final factor = math.pow(10, decimals);
    return (this * factor).round() / factor;
  }
}

extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(1.days);
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);
  
  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
  
  /// Check if date is within range
  bool isWithinRange(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }
}

extension ListExtensions<T> on List<T> {
  /// Check if list is null or empty
  bool get isNullOrEmpty => isEmpty;
  
  /// Check if list is not empty
  bool get isNotEmpty => !isEmpty;
  
  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;
  
  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;
  
  /// Chunk list into smaller lists
  List<List<T>> chunked(int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += chunkSize) {
      chunks.add(sublist(i, i + chunkSize > length ? length : i + chunkSize));
    }
    return chunks;
  }
  
  /// Remove duplicates
  List<T> distinct() {
    final seen = <T>{};
    return where((element) => seen.add(element)).toList();
  }
}

extension BuildContextExtensions on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);
  
  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  /// Get screen size
  Size get screenSize => mediaQuery.size;
  
  /// Get screen width
  double get screenWidth => screenSize.width;
  
  /// Get screen height
  double get screenHeight => screenSize.height;
  
  /// Check if device is tablet
  bool get isTablet => screenWidth > 600;
  
  /// Check if device is mobile
  bool get isMobile => screenWidth <= 600;
  
  /// Get safe area padding
  EdgeInsets get safePadding => mediaQuery.padding;
  
  /// Check if keyboard is visible
  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;
  
  /// Hide keyboard
  void hideKeyboard {
    FocusScope.of(this).unfocus();
  }
  
  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
      ),
    );
  }
}
