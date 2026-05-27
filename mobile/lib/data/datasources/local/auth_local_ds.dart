import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/storage_constants.dart';
import '../../../core/error/exceptions.dart';
import 'local_datasource.dart';

/// Auth local datasource
class AuthLocalDataSource {
  final LocalDataSource localDataSource;
  
  AuthLocalDataSource(this.localDataSource);
  
  /// Store access token
  Future<void> storeAccessToken(String token) async {
    try {
      await localDataSource.put(StorageConstants.authBox, StorageConstants.accessToken, token);
    } catch (e) {
      throw StorageException('Failed to store access token: $e');
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await localDataSource.get<String>(StorageConstants.authBox, StorageConstants.accessToken);
    } catch (e) {
      throw StorageException('Failed to get access token: $e');
    }
  }
  
  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await localDataSource.put(StorageConstants.authBox, StorageConstants.refreshToken, token);
    } catch (e) {
      throw StorageException('Failed to store refresh token: $e');
    }
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await localDataSource.get<String>(StorageConstants.authBox, StorageConstants.refreshToken);
    } catch (e) {
      throw StorageException('Failed to get refresh token: $e');
    }
  }
  
  /// Store user ID
  Future<void> storeUserId(String userId) async {
    try {
      await localDataSource.put(StorageConstants.authBox, 'user_id', userId);
    } catch (e) {
      throw StorageException('Failed to store user ID: $e');
    }
  }
  
  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await localDataSource.get<String>(StorageConstants.authBox, 'user_id');
    } catch (e) {
      throw StorageException('Failed to get user ID: $e');
    }
  }
  
  /// Clear auth data
  Future<void> clearAuthData() async {
    try {
      final box = await localDataSource.getBox(StorageConstants.authBox);
      await box.delete(StorageConstants.accessToken);
      await box.delete(StorageConstants.refreshToken);
      await box.delete('user_id');
    } catch (e) {
      throw StorageException('Failed to clear auth data: $e');
    }
  }
  
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
