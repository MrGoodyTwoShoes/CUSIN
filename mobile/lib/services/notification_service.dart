import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/constants/app_constants.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification service for local push notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  NotificationService();
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        _handleNotificationTap(response);
      },
    );
    
    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  
  Future<void> showIncidentNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'incident_channel',
      'Incident Notifications',
      channelDescription: 'Notifications for new incidents nearby',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  Future<void> showEmergencyNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'emergency_channel',
      'Emergency Alerts',
      channelDescription: 'Critical emergency alerts',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      category: AndroidNotificationCategory.alarm,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  Future<void> showCircleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'circle_channel',
      'Circle Updates',
      channelDescription: 'Notifications for circle updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      showWhen: true,
    );
    
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  
  void _handleNotificationTap(NotificationResponse response) {
    // Navigate to appropriate screen based on payload
    // TODO: Implement navigation logic
  }
  
  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
  
  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
