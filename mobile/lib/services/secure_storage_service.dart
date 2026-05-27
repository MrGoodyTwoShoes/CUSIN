import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/storage_constants.dart';
import '../core/error/exceptions.dart';

/// Secure storage service provider
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Secure storage service using flutter_secure_storage
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  
  /// Store access token
  Future<void> storeAccessToken(String token) async {
    try {
      await _storage.write(key: StorageConstants.accessToken, value: token);
    } catch (e) {
      throw StorageException('Failed to store access token: $e');
    }
  }
  
  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: StorageConstants.accessToken);
    } catch (e) {
      throw StorageException('Failed to get access token: $e');
    }
  }
  
  /// Store refresh token
  Future<void> storeRefreshToken(String token) async {
    try {
      await _storage.write(key: StorageConstants.refreshToken, value: token);
    } catch (e) {
      throw StorageException('Failed to store refresh token: $e');
    }
  }
  
  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: StorageConstants.refreshToken);
    } catch (e) {
      throw StorageException('Failed to get refresh token: $e');
    }
  }
  
  /// Store device ID
  Future<void> storeDeviceId(String deviceId) async {
    try {
      await _storage.write(key: StorageConstants.deviceId, value: deviceId);
    } catch (e) {
      throw StorageException('Failed to store device ID: $e');
    }
  }
  
  /// Get device ID
  Future<String?> getDeviceId() async {
    try {
      return await _storage.read(key: StorageConstants.deviceId);
    } catch (e) {
      throw StorageException('Failed to get device ID: $e');
    }
  }
  
  /// Delete all auth data
  Future<void> deleteAllAuthData() async {
    try {
      await _storage.delete(key: StorageConstants.accessToken);
      await _storage.delete(key: StorageConstants.refreshToken);
      await _storage.delete(key: StorageConstants.deviceId);
    } catch (e) {
      throw StorageException('Failed to delete auth data: $e');
    }
  }
  
  /// Check if biometric auth is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _storage.isAvailable();
      return isAvailable;
    } catch (e) {
      return false;
    }
  }
  
  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      final isAuthenticated = await _storage.authenticate(
        localizedReason: reason,
      );
      return isAuthenticated;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear all secure storage
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw StorageException('Failed to clear secure storage: $e');
    }
  }
}
