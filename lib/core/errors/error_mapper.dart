import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Maps various error types to appropriate Failures
/// This ensures consistent error handling across the application
class ErrorMapper {
  /// Maps DioException to appropriate Failure
  static Failure mapDioErrorToFailure(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutFailure('Request timeout. Please check your connection.');
        
      case DioExceptionType.connectionError:
        return NetworkFailure('No internet connection. Please check your network.');
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);
        
        if (statusCode == null) {
          return ServerFailure('Server error: $message');
        }
        
        return _mapStatusCodeToFailure(statusCode, message);
        
      case DioExceptionType.cancel:
        return NetworkFailure('Request was cancelled');
        
      case DioExceptionType.unknown:
      default:
        return NetworkFailure('Network error: ${error.message ?? 'Unknown error'}');
    }
  }
  
  /// Maps HTTP status codes to appropriate Failures
  static Failure _mapStatusCodeToFailure(int statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ValidationFailure('Bad request: $message');
      case 401:
        return AuthFailure('Unauthorized: $message');
      case 403:
        return AuthFailure('Forbidden: $message');
      case 404:
        return ServerFailure('Not found: $message');
      case 409:
        return ValidationFailure('Conflict: $message');
      case 422:
        return ValidationFailure('Validation error: $message');
      case 429:
        return ServerFailure('Too many requests. Please try again later.');
      case 500:
        return ServerFailure('Internal server error: $message');
      case 502:
      case 503:
      case 504:
        return ServerFailure('Server temporarily unavailable. Please try again later.');
      default:
        return ServerFailure('Server error ($statusCode): $message');
    }
  }
  
  /// Maps custom Exceptions to Failures
  static Failure mapExceptionToFailure(Exception exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message);
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is AuthException) {
      return AuthFailure(exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(exception.message);
    } else if (exception is TimeoutException) {
      return TimeoutFailure(exception.message);
    }
    
    return ServerFailure('Unknown error: ${exception.toString()}');
  }
  
  /// Extracts error message from response data
  static String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'Unknown error';
    
    if (responseData is Map<String, dynamic>) {
      // Try common error message fields
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['detail'] ?? 
             'Unknown error';
    }
    
    if (responseData is String) {
      return responseData;
    }
    
    return 'Unknown error';
  }
  
  /// Maps generic errors to Failures
  static Failure mapGenericErrorToFailure(dynamic error) {
    if (error is DioException) {
      return mapDioErrorToFailure(error);
    }
    
    if (error is Exception) {
      return mapExceptionToFailure(error);
    }
    
    return ServerFailure('Unexpected error: ${error.toString()}');
  }
}

/// Additional Failure types for better error categorization
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message);
}