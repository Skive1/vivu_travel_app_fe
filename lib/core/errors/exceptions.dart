
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;
  
  const ServerException(this.message, [this.statusCode, this.errorCode]);
  
  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException(this.message);
  
  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? errorCode;
  
  const AuthException(this.message, [this.errorCode]);
  
  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final String? field;
  
  const ValidationException(this.message, [this.field]);
  
  @override
  String toString() => 'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

class TimeoutException implements Exception {
  final String message;
  final Duration? timeout;
  
  const TimeoutException(this.message, [this.timeout]);
  
  @override
  String toString() => 'TimeoutException: $message${timeout != null ? ' (Timeout: ${timeout!.inSeconds}s)' : ''}';
}