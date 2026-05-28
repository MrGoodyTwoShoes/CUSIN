import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/storage_constants.dart';
import '../error/exceptions.dart';
import '../utils/extensions.dart';
import 'network_info.dart';

/// API interceptor provider
final apiInterceptorProvider = Provider<ApiInterceptor>((ref) {
  return ApiInterceptor(ref.read(networkInfoProvider));
});

/// API interceptor for auth, logging, and error handling
class ApiInterceptor extends Interceptor {
  final NetworkInfo _networkInfo;
  final Dio _dio = Dio();
  
  ApiInterceptor(this._networkInfo) {
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));
  }
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add auth token if available
    // TODO: Implement token retrieval from secure storage
    
    // Add device ID
    // TODO: Add device ID header
    
    // Add request ID for tracking
    options.headers['X-Request-ID'] = generateRequestId();
    
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Log successful response
    super.onResponse(response, handler);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle different error types
    final error = _handleError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: error,
    ));
  }
  
  AppException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network.');
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');
      
      case DioExceptionType.unknown:
        return NetworkException('An unexpected error occurred. Please try again.');
      
      default:
        return ServerException('An unknown error occurred.');
    }
  }
  
  AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final message = error.response?.data?['message'] ?? 'An error occurred';
    
    switch (statusCode) {
      case 400:
        return ValidationException(message);
      case 401:
        return AuthException('Authentication failed. Please login again.');
      case 403:
        return AuthException('You do not have permission to perform this action.');
      case 404:
        return NotFoundException(message);
      case 409:
        return ConflictException(message);
      case 429:
        return RateLimitException('Too many requests. Please try again later.');
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('Server error. Please try again later.');
      default:
        return ServerException(message, statusCode);
    }
  }
  
  String generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
