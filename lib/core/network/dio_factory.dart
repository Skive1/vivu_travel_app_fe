import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'endpoints.dart';
import 'api_config.dart';
import '../utils/token_storage.dart';
import 'auth_interceptor.dart';
import 'timing_interceptor.dart';

class DioFactory {
  static Completer<String?>? _refreshCompleter;
  static bool _isRefreshing = false;
  static Dio? _authDio;
  static Dio? _shared;

  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
      headers: NetworkConfig.defaultHeaders,
      maxRedirects: 3,
      followRedirects: true,
      validateStatus: (status) => status != null && status >= 200 && status < 300,
    ));

    dio.httpClientAdapter = DefaultHttpClientAdapter()
      ..onHttpClientCreate = (client) {
        client.connectionTimeout = Duration(milliseconds: NetworkConfig.connectTimeout);
        client.idleTimeout = Duration(seconds: 30); // Keep connections alive
        client.autoUncompress = true;
        return client;
      };
    dio.interceptors.add(TimingInterceptor());
    dio.interceptors.add(AuthInterceptor());

    _shared = dio;
    return dio;
  }

  static Dio get sharedDio {
    return _shared ?? create();
  }

  static Future<String?> refreshToken() async {
    // Nếu đang refresh, đợi kết quả để tránh race condition
    if (_isRefreshing && _refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }
    
    // Set flag để prevent multiple refresh calls
    _isRefreshing = true;
    final completer = Completer<String?>();
    _refreshCompleter = completer;
    
    try {
      final refreshToken = TokenStorage.refreshTokenSync;
      if (refreshToken == null) {
        if (kDebugMode) debugPrint('RefreshToken: No refresh token available');
        completer.complete(null);
        return null;
      }

      if (kDebugMode) debugPrint('RefreshToken: Attempting to refresh token');
      
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
          
          if (kDebugMode) debugPrint('RefreshToken: Successfully refreshed token');
          completer.complete(newAccessToken);
          return newAccessToken;
        }
      }
      
      if (kDebugMode) debugPrint('RefreshToken: Failed to refresh - invalid response');
      completer.complete(null);
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('RefreshToken: Error during refresh: $e');
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