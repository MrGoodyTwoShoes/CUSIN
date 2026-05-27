/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  
  AppException(this.message, [this.statusCode]);
  
  @override
  String toString() => message;
}

/// Server exceptions (5xx errors)
class ServerException extends AppException {
  ServerException(String message, [int? statusCode]) 
      : super(message, statusCode ?? 500);
}

/// Network exceptions (no internet, timeout, etc.)
class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

/// Authentication exceptions (401, 403)
class AuthException extends AppException {
  AuthException(String message, [int? statusCode]) 
      : super(message, statusCode ?? 401);
}

/// Validation exceptions (400, 422)
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  
  ValidationException(String message, [this.errors, int? statusCode]) 
      : super(message, statusCode ?? 400);
}

/// Not found exceptions (404)
class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

/// Conflict exceptions (409)
class ConflictException extends AppException {
  ConflictException(String message) : super(message, 409);
}

/// Rate limit exceptions (429)
class RateLimitException extends AppException {
  RateLimitException(String message) : super(message, 429);
}

/// Cache exceptions
class CacheException extends AppException {
  CacheException(String message) : super(message);
}

/// Location exceptions
class LocationException extends AppException {
  LocationException(String message) : super(message);
}

/// Permission exceptions
class PermissionException extends AppException {
  PermissionException(String message) : super(message);
}

/// Storage exceptions
class StorageException extends AppException {
  StorageException(String message) : super(message);
}
