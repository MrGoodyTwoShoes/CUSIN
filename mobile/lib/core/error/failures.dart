/// Base failure class for use case failures
abstract class Failure {
  final String message;
  
  Failure(this.message);
  
  @override
  String toString() => message;
}

/// Server failure
class ServerFailure extends Failure {
  final int? statusCode;
  
  ServerFailure(String message, [this.statusCode]) : super(message);
}

/// Network failure
class NetworkFailure extends Failure {
  NetworkFailure(String message) : super(message);
}

/// Authentication failure
class AuthFailure extends Failure {
  AuthFailure(String message) : super(message);
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  
  ValidationFailure(String message, [this.errors]) : super(message);
}

/// Not found failure
class NotFoundFailure extends Failure {
  NotFoundFailure(String message) : super(message);
}

/// Conflict failure
class ConflictFailure extends Failure {
  ConflictFailure(String message) : super(message);
}

/// Rate limit failure
class RateLimitFailure extends Failure {
  RateLimitFailure(String message) : super(message);
}

/// Cache failure
class CacheFailure extends Failure {
  CacheFailure(String message) : super(message);
}

/// Location failure
class LocationFailure extends Failure {
  LocationFailure(String message) : super(message);
}

/// Permission failure
class PermissionFailure extends Failure {
  PermissionFailure(String message) : super(message);
}

/// Storage failure
class StorageFailure extends Failure {
  StorageFailure(String message) : super(message);
}

/// Unknown failure
class UnknownFailure extends Failure {
  UnknownFailure(String message) : super(message);
}
