import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  late final Dio _dio;
  
  APIService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final authBox = Hive.box('authBox');
        final token = authBox.get('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors
        if (error.response?.statusCode == 401) {
          // Token expired, clear auth
          _clearAuth();
        }
        handler.next(error);
      },
    ));
  }
  
  Future<void> _clearAuth() async {
    final authBox = Hive.box('authBox');
    await authBox.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  
  // Auth endpoints
  Future<Map<String, dynamic>> register(String phone) async {
    try {
      final response = await _dio.post('/auth/register', data: {'phone': phone});
      if (response.data['success']) {
        final token = response.data['data']['token'];
        final userId = response.data['data']['user_id'];
        
        // Store auth data
        final authBox = Hive.box('authBox');
        await authBox.put('token', token);
        await authBox.put('userId', userId);
        
        return response.data['data'];
      }
      throw Exception('Registration failed');
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }
  
  Future<Map<String, dynamic>> login(String phone) async {
    try {
      final response = await _dio.post('/auth/login', data: {'phone': phone});
      if (response.data['success']) {
        final token = response.data['data']['token'];
        final userId = response.data['data']['user_id'];
        
        // Store auth data
        final authBox = Hive.box('authBox');
        await authBox.put('token', token);
        await authBox.put('userId', userId);
        
        return response.data['data'];
      }
      throw Exception('Login failed');
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }
  
  Future<Map<String, dynamic>> verifyPhone(String phone, String code) async {
    try {
      final response = await _dio.post('/auth/verify-phone', data: {
        'phone': phone,
        'code': code,
      });
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception('Verification failed');
    } catch (e) {
      throw Exception('Verification error: $e');
    }
  }
  
  // Incident endpoints
  Future<Map<String, dynamic>> createIncident({
    required String incidentType,
    String? description,
    required double latitude,
    required double longitude,
    String severity = 'medium',
  }) async {
    try {
      final response = await _dio.post('/incidents', data: {
        'incident_type': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'severity': severity,
      });
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception('Incident creation failed');
    } catch (e) {
      throw Exception('Incident creation error: $e');
    }
  }
  
  Future<List<dynamic>> getNearbyIncidents({
    required double lat,
    required double lng,
    double radius = 2,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get('/incidents', queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
        'limit': limit,
      });
      if (response.data['success']) {
        return response.data['data']['incidents'];
      }
      throw Exception('Failed to get incidents');
    } catch (e) {
      throw Exception('Get incidents error: $e');
    }
  }
  
  Future<List<dynamic>> getHeatmap({String layer = 'recent'}) async {
    try {
      final response = await _dio.get('/incidents/heatmap', queryParameters: {
        'layer': layer,
      });
      if (response.data['success']) {
        return response.data['data']['heatmap'];
      }
      throw Exception('Failed to get heatmap');
    } catch (e) {
      throw Exception('Get heatmap error: $e');
    }
  }
  
  Future<Map<String, dynamic>> corroborateIncident(String incidentId) async {
    try {
      final response = await _dio.post('/incidents/$incidentId/corroborate');
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception('Corroboration failed');
    } catch (e) {
      throw Exception('Corroboration error: $e');
    }
  }
  
  // User endpoints
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.data['success']) {
        return response.data['data']['user'];
      }
      throw Exception('Failed to get user');
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }
}
