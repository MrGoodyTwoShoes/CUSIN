import '../../../core/constants/storage_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/incident_model.dart';
import 'local_datasource.dart';

/// Incidents local datasource
class IncidentsLocalDataSource {
  final LocalDataSource localDataSource;
  
  IncidentsLocalDataSource(this.localDataSource);
  
  /// Cache incidents
  Future<void> cacheIncidents(List<IncidentModel> incidents) async {
    try {
      final box = await localDataSource.getBox(StorageConstants.incidentBox);
      await box.put('cached_incidents', incidents);
      await box.put('cache_timestamp', DateTime.now().toIso8601String());
    } catch (e) {
      throw StorageException('Failed to cache incidents: $e');
    }
  }
  
  /// Get cached incidents
  Future<List<IncidentModel>> getCachedIncidents() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.incidentBox);
      final incidents = await box.get('cached_incidents');
      
      if (incidents == null) return [];
      
      return (incidents as List).map((json) => IncidentModel.fromJson(json)).toList();
    } catch (e) {
      throw StorageException('Failed to get cached incidents: $e');
    }
  }
  
  /// Get cache timestamp
  Future<DateTime?> getCacheTimestamp() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.incidentBox);
      final timestamp = await box.get('cache_timestamp');
      
      if (timestamp == null) return null;
      
      return DateTime.parse(timestamp as String);
    } catch (e) {
      throw StorageException('Failed to get cache timestamp: $e');
    }
  }
  
  /// Check if cache is valid
  Future<bool> isCacheValid({int maxAgeHours = 24}) async {
    final timestamp = await getCacheTimestamp();
    if (timestamp == null) return false;
    
    final age = DateTime.now().difference(timestamp);
    return age.inHours < maxAgeHours;
  }
  
  /// Add incident to offline queue
  Future<void> addIncidentToQueue(IncidentModel incident) async {
    try {
      final box = await localDataSource.getBox(StorageConstants.offlineQueueBox);
      final queue = await box.get(StorageConstants.incidentQueue, defaultValue: []);
      queue.add(incident.toJson());
      await box.put(StorageConstants.incidentQueue, queue);
    } catch (e) {
      throw StorageException('Failed to add incident to queue: $e');
    }
  }
  
  /// Get offline incident queue
  Future<List<Map<String, dynamic>>> getIncidentQueue() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.offlineQueueBox);
      final queue = await box.get(StorageConstants.incidentQueue, defaultValue: []);
      return List<Map<String, dynamic>>.from(queue);
    } catch (e) {
      throw StorageException('Failed to get incident queue: $e');
    }
  }
  
  /// Remove incident from queue
  Future<void> removeIncidentFromQueue(int index) async {
    try {
      final box = await localDataSource.getBox(StorageConstants.offlineQueueBox);
      final queue = await box.get(StorageConstants.incidentQueue, defaultValue: []);
      queue.removeAt(index);
      await box.put(StorageConstants.incidentQueue, queue);
    } catch (e) {
      throw StorageException('Failed to remove incident from queue: $e');
    }
  }
  
  /// Clear incident queue
  Future<void> clearIncidentQueue() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.offlineQueueBox);
      await box.delete(StorageConstants.incidentQueue);
    } catch (e) {
      throw StorageException('Failed to clear incident queue: $e');
    }
  }
  
  /// Get queue size
  Future<int> getQueueSize() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.offlineQueueBox);
      final queue = await box.get(StorageConstants.incidentQueue, defaultValue: []);
      return queue.length;
    } catch (e) {
      throw StorageException('Failed to get queue size: $e');
    }
  }
}
