import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

/// Abstract remote datasource interface
abstract class RemoteDataSource {
  Future<void> init();
}

/// Remote datasource implementation using Dio
class RemoteDataSourceImpl implements RemoteDataSource {
  final DioClient dioClient;
  late final Dio _dio;
  
  RemoteDataSourceImpl(this.dioClient) {
    _dio = dioClient.dio;
  }
  
  @override
  Future<void> init() async {
    // Initialize any required resources
  }
  
  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }
  
  /// POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  /// PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  /// DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      rethrow;
    }
  }
  
  /// PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Upload file
  Future<Response> uploadFile(String path, String filePath, {Map<String, dynamic>? data}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });
      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Upload multiple files
  Future<Response> uploadFiles(String path, List<String> filePaths, {Map<String, dynamic>? data}) async {
    try {
      final files = await Future.wait(
        filePaths.map((path) => MultipartFile.fromFile(path)),
      );
      
      final formData = FormData.fromMap({
        'files': files,
        ...?data,
      });
      
      return await _dio.post(path, data: formData);
    } catch (e) {
      rethrow;
    }
  }
}
