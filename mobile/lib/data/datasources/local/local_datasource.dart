import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/error/exceptions.dart';

/// Abstract local datasource interface
abstract class LocalDataSource {
  Future<void> init();
  Future<void> close();
}

/// Local datasource implementation using Hive
class LocalDataSourceImpl implements LocalDataSource {
  final Map<String, Box> _boxes = {};
  
  @override
  Future<void> init() async {
    await Hive.initFlutter();
  }
  
  @override
  Future<void> close() async {
    for (final box in _boxes.values) {
      await box.close();
    }
  }
  
  /// Get or open a Hive box
  Future<Box> getBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      return _boxes[boxName]!;
    }
    
    final box = await Hive.openBox(boxName);
    _boxes[boxName] = box;
    return box;
  }
  
  /// Get value from box
  Future<T?> get<T>(String boxName, String key) async {
    try {
      final box = await getBox(boxName);
      return box.get(key) as T?;
    } catch (e) {
      throw StorageException('Failed to get value: $e');
    }
  }
  
  /// Put value in box
  Future<void> put(String boxName, String key, dynamic value) async {
    try {
      final box = await getBox(boxName);
      await box.put(key, value);
    } catch (e) {
      throw StorageException('Failed to put value: $e');
    }
  }
  
  /// Delete value from box
  Future<void> delete(String boxName, String key) async {
    try {
      final box = await getBox(boxName);
      await box.delete(key);
    } catch (e) {
      throw StorageException('Failed to delete value: $e');
    }
  }
  
  /// Get all values from box
  Future<List<dynamic>> getAll(String boxName) async {
    try {
      final box = await getBox(boxName);
      return box.values.toList();
    } catch (e) {
      throw StorageException('Failed to get all values: $e');
    }
  }
  
  /// Clear all values from box
  Future<void> clear(String boxName) async {
    try {
      final box = await getBox(boxName);
      await box.clear();
    } catch (e) {
      throw StorageException('Failed to clear box: $e');
    }
  }
  
  /// Check if key exists
  Future<bool> containsKey(String boxName, String key) async {
    try {
      final box = await getBox(boxName);
      return box.containsKey(key);
    } catch (e) {
      throw StorageException('Failed to check key: $e');
    }
  }
  
  /// Get box length
  Future<int> getLength(String boxName) async {
    try {
      final box = await getBox(boxName);
      return box.length;
    } catch (e) {
      throw StorageException('Failed to get box length: $e');
    }
  }
}
