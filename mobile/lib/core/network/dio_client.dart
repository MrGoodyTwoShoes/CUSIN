import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_interceptor.dart';

/// Dio client provider
final dioClientProvider = Provider<Dio>((ref) {
  return DioClient(ref.read(apiInterceptorProvider)).dio;
});

/// Dio client configuration
class DioClient {
  final Dio _dio;
  
  DioClient(ApiInterceptor interceptor) : _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: ApiConstants.connectTimeout,
    receiveTimeout: ApiConstants.receiveTimeout,
    sendTimeout: ApiConstants.sendTimeout,
    headers: {
      ApiConstants.contentType: ApiConstants.applicationJson,
    },
  )) {
    _dio.interceptors.add(interceptor);
  }
  
  Dio get dio => _dio;
}
