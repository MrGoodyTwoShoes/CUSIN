import 'package:intl/intl.dart';

class Formatters {
  /// Format phone number to Kenyan format
  static String formatPhone(String phone) {
    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    
    // If starts with 0, convert to +254
    if (cleanPhone.startsWith('0') && cleanPhone.length == 10) {
      return '+254${cleanPhone.substring(1)}';
    }
    
    // If starts with 254, add +
    if (cleanPhone.startsWith('254') && cleanPhone.length == 12) {
      return '+$cleanPhone';
    }
    
    // If already has +, return as is
    if (cleanPhone.startsWith('254') && phone.startsWith('+')) {
      return phone;
    }
    
    return phone;
  }
  
  /// Format date to readable string
  static String formatDate(DateTime date, {String pattern = 'MMM dd, yyyy'}) {
    return DateFormat(pattern).format(date);
  }
  
  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }
  
  /// Format time ago
  static String formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
  
  /// Format trust score with color indicator
  static String formatTrustScore(double score) {
    return score.toStringAsFixed(1);
  }
  
  /// Format distance in meters/kilometers
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
  }
  
  /// Format incident type for display
  static String formatIncidentType(String type) {
    return type
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
  
  /// Format severity with emoji
  static String formatSeverity(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return '🟢 Low';
      case 'medium':
        return '🟡 Medium';
      case 'high':
        return '🟠 High';
      case 'critical':
        return '🔴 Critical';
      default:
        return severity;
    }
  }
  
  /// Format confidence score as percentage
  static String formatConfidence(double confidence) {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }
  
  /// Format number with commas
  static String formatNumber(int number) {
    return NumberFormat.decimalPattern().format(number);
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Mask phone number for privacy
  static String maskPhone(String phone) {
    if (phone.length < 4) return phone;
    final masked = '*' * (phone.length - 4);
    return masked + phone.substring(phone.length - 4);
  }
  
  /// Format duration
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
