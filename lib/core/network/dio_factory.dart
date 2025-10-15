import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:async';
import 'endpoints.dart';
import 'api_config.dart';
import '../utils/token_storage.dart';

class DioFactory {
  // Token refresh lock để tránh race condition
  static Completer<String?>? _refreshCompleter;
  static bool _isRefreshing = false;
  
  // Separate Dio instance for refresh token calls (without interceptors)
  static Dio? _authDio;

  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
      headers: NetworkConfig.defaultHeaders,
      // Performance optimizations
      maxRedirects: 3,
      followRedirects: true,
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ));

    // HTTP/2 Connection Pooling for better performance
    dio.httpClientAdapter = DefaultHttpClientAdapter()
      ..onHttpClientCreate = (client) {
        client.connectionTimeout = Duration(milliseconds: NetworkConfig.connectTimeout);
        client.idleTimeout = Duration(seconds: 30); // Keep connections alive
        // Enable compression for faster data transfer
        client.autoUncompress = true;
        return client;
      };

    // Add compression interceptor for better performance
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => print('HTTP: $obj'),
    ));

    // Token Interceptor with Preemptive Refresh Logic
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip refresh token path to avoid interference
          if (options.path.contains(Endpoints.refreshToken)) {
            return handler.next(options);
          }
          
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            // Log token TTL before request
            final timeRemaining = await TokenStorage.getTokenTimeRemaining();
            print('DioFactory: Token TTL before request: ${timeRemaining?.inMinutes ?? 0} minutes');
            
            // Chỉ refresh nếu token sắp hết hạn và chưa có refresh đang chạy
            if (await TokenStorage.isTokenNearExpiry(threshold: Duration(minutes: 3)) && !_isRefreshing) {
              print('DioFactory: Preemptive refresh triggered - using _authDio');
              final newToken = await _refreshToken();
              if (newToken != null) {
                print('DioFactory: Token refreshed successfully - old: ${token.substring(0, 10)}... new: ${newToken.substring(0, 10)}...');
                options.headers['Authorization'] = 'Bearer $newToken';
              } else {
                // Nếu refresh fail, vẫn dùng token cũ và để error handler xử lý
                print('DioFactory: Preemptive refresh failed - using old token');
                options.headers['Authorization'] = 'Bearer $token';
              }
            } else {
              print('DioFactory: Using current token (no refresh needed)');
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            
            // Nếu đây là refresh token request, không retry
            if (requestOptions.path.contains(Endpoints.refreshToken)) {
              await TokenStorage.clearAll();
              return handler.reject(error);
            }
            
            try {
              // Prevent infinite retry loop
              final hasRetried = requestOptions.extra['retried'] == true;
              if (hasRetried) {
                await TokenStorage.clearAll();
                return handler.reject(error);
              }

              // Chỉ refresh nếu chưa có refresh đang chạy
              if (!_isRefreshing) {
                print('DioFactory: Reactive refresh triggered (401 error) - using _authDio');
                final newToken = await _refreshToken();
                if (newToken != null) {
                  print('DioFactory: Reactive refresh successful - retrying request with new token');
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  requestOptions.extra['retried'] = true;
                  final retryResponse = await dio.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                }
              } else if (_refreshCompleter != null) {
                // Nếu đang có refresh đang chạy, đợi kết quả
                print('DioFactory: Waiting for existing refresh to complete');
                final newToken = await _refreshCompleter!.future;
                if (newToken != null) {
                  print('DioFactory: Got new token from existing refresh - retrying request');
                  requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  requestOptions.extra['retried'] = true;
                  final retryResponse = await dio.fetch(requestOptions);
                  return handler.resolve(retryResponse);
                }
              }
            } catch (refreshError) {
              await TokenStorage.clearAll();
            }
          }
          
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<String?> _refreshToken() async {
    // Nếu đang refresh, đợi kết quả để tránh race condition
    if (_isRefreshing && _refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }
    
    // Set flag để prevent multiple refresh calls
    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshCompleter = completer;
    
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        print('RefreshToken: No refresh token available');
        completer.complete(null);
        return null;
      }

      print('RefreshToken: Attempting to refresh token');
      
      // Use separate Dio instance for refresh token call
      final authDio = _createAuthDio();
      
      // Call refresh endpoint with POST method and refreshToken as query parameter
      final response = await authDio.post(
        '${Endpoints.refreshToken}?refreshToken=$refreshToken',
        options: Options(
          // Set timeout để tránh hang
          receiveTimeout: Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          // Use secure token rotation - only save refresh token if it's valid
          await TokenStorage.saveBothTokensSecure(newAccessToken, newRefreshToken);
          
          print('RefreshToken: Successfully refreshed token');
          completer.complete(newAccessToken);
          return newAccessToken;
        }
      }
      
      print('RefreshToken: Failed to refresh - invalid response');
      completer.complete(null);
      return null;
    } catch (e) {
      print('RefreshToken: Error during refresh: $e');
      completer.complete(null);
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  // Method để clear refresh lock khi logout
  static void clearRefreshLock() {
    _refreshCompleter = null;
    _isRefreshing = false;
  }

  // Create separate Dio instance for auth calls (without interceptors)
  static Dio _createAuthDio() {
    if (_authDio == null) {
      _authDio = Dio(BaseOptions(
        baseUrl: NetworkConfig.baseUrl,
        connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
        headers: NetworkConfig.defaultHeaders,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ));
      return _authDio!;
    }
    return _authDio!;
  }
}