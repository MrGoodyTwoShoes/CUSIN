import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import '../core/constants/storage_constants.dart';
import '../core/network/network_info.dart';

/// Sync service provider
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.read(networkInfoProvider));
});

/// Background sync service for offline data
class SyncService {
  final NetworkInfo _networkInfo;
  
  SyncService(this._networkInfo);
  
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Schedule periodic sync every 15 minutes
    await Workmanager().registerPeriodicTask(
      'syncTask',
      'syncTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  Future<void> syncNow() async {
    if (await _networkInfo.isConnected) {
      await _syncOfflineQueue();
    }
  }
  
  Future<void> _syncOfflineQueue() async {
    // Sync pending incidents
    await _syncIncidentQueue();
    
    // Sync pending auth operations
    await _syncAuthQueue();
    
    // Update last sync timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageConstants.lastSyncTimestamp,
      DateTime.now().toIso8601String(),
    );
  }
  
  Future<void> _syncIncidentQueue() async {
    final queueBox = await Hive.openBox(StorageConstants.offlineQueueBox);
    final incidentQueue = queueBox.get(StorageConstants.incidentQueue, defaultValue: []);
    
    // TODO: Implement incident sync logic
    // - Iterate through queue
    // - Send to API
    // - Remove from queue on success
    // - Retry on failure
  }
  
  Future<void> _syncAuthQueue() async {
    final queueBox = await Hive.openBox(StorageConstants.offlineQueueBox);
    final authQueue = queueBox.get(StorageConstants.authQueue, defaultValue: []);
    
    // TODO: Implement auth sync logic
  }
  
  void dispose() {
    Workmanager().cancelAll();
  }
}

/// Callback dispatcher for Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Perform sync
    // TODO: Initialize dependencies and perform sync
    
    return Future.value(true);
  });
}
