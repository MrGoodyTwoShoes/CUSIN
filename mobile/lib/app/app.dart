import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_constants.dart';
import 'router.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/websocket_service.dart';
import '../presentation/providers/providers.dart';
import 'theme/app_theme.dart';

class CUSINApp extends ConsumerStatefulWidget {
  const CUSINApp({super.key});

  @override
  ConsumerState<CUSINApp> createState() => _CUSINAppState();
}

class _CUSINAppState extends ConsumerState<CUSINApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Open Hive boxes
    await Hive.openBox(StorageConstants.authBox);
    await Hive.openBox(StorageConstants.userBox);
    await Hive.openBox(StorageConstants.incidentBox);
    await Hive.openBox(StorageConstants.circleBox);
    await Hive.openBox(StorageConstants.contactBox);
    await Hive.openBox(StorageConstants.cacheBox);
    await Hive.openBox(StorageConstants.offlineQueueBox);
    
    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize notification service
    await ref.read(notificationServiceProvider).initialize();
    
    // Initialize location service
    await ref.read(locationServiceProvider.notifier).initialize();
    
    // Initialize WebSocket service
    await ref.read(websocketServiceProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'CUSIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
