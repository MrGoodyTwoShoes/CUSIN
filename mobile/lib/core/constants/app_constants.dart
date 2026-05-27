class AppConstants {
  // App Info
  static const String appName = 'CUSIN';
  static const String appVersion = '1.0.0';
  
  // Mapbox
  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: 'YOUR_MAPBOX_ACCESS_TOKEN',
  );
  static const String mapboxStyleUrl = 'mapbox://styles/mapbox/streets-v12';
  static const double defaultMapZoom = 13.0;
  static const double minMapZoom = 10.0;
  static const double maxMapZoom = 18.0;
  
  // Location
  static const double locationFuzzRadius = 75.0; // meters
  static const int h3Resolution = 9;
  static const double defaultLocationAccuracy = 50.0; // meters
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache
  static const int cacheDurationHours = 24;
  static const int maxCacheSizeMB = 50;
  
  // Offline
  static const int maxOfflineQueueSize = 100;
  static const Duration syncRetryDelay = Duration(minutes: 5);
  
  // UI
  static const double defaultBorderRadius = 12.0;
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double minTouchTarget = 48.0;
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // Trust Score
  static const double minTrustScore = 0.0;
  static const double maxTrustScore = 100.0;
  static const double defaultTrustScore = 50.0;
  
  // Incident
  static const int maxDescriptionLength = 1000;
  static const int maxEvidenceCount = 5;
  static const double maxEvidenceSizeMB = 10.0;
  
  // Circle
  static const int maxCircleMembers = 500;
  static const int maxUserCircles = 20;
  
  // Contact
  static const int maxTrustedContacts = 10;
  
  // Notification
  static const int maxNotificationRetentionDays = 30;
  
  // Session
  static const Duration sessionTimeout = Duration(days: 7);
  
  // Rate Limiting
  static const int maxIncidentsPerHour = 10;
  static const int maxAuthAttemptsPerHour = 5;
}
