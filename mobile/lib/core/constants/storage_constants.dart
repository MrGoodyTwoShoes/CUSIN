class StorageConstants {
  // Hive Boxes
  static const String authBox = 'authBox';
  static const String userBox = 'userBox';
  static const String incidentBox = 'incidentBox';
  static const String circleBox = 'circleBox';
  static const String contactBox = 'contactBox';
  static const String cacheBox = 'cacheBox';
  static const String offlineQueueBox = 'offlineQueueBox';
  
  // Secure Storage Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String deviceId = 'device_id';
  
  // SharedPreferences Keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String language = 'language';
  static const String themeMode = 'theme_mode';
  static const String locationPermissionGranted = 'location_permission_granted';
  static const String notificationPermissionGranted = 'notification_permission_granted';
  static const String lastSyncTimestamp = 'last_sync_timestamp';
  static const String appVersion = 'app_version';
  
  // Cache Keys
  static const String incidentsCache = 'incidents_cache';
  static const String circlesCache = 'circles_cache';
  static const String heatmapCache = 'heatmap_cache';
  static const String userProfileCache = 'user_profile_cache';
  
  // Offline Queue Keys
  static const String incidentQueue = 'incident_queue';
  static const String authQueue = 'auth_queue';
}
