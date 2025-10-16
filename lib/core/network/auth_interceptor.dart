import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/token_storage.dart';
import 'dio_factory.dart';

class AuthInterceptor extends Interceptor {
  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = TokenStorage.accessTokenSync;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Prevent looping on refresh endpoint itself
    final path = err.requestOptions.path;
    if (path.contains('refresh')) {
      return handler.next(err);
    }

    // Ensure single refresh in-flight
    try {
      final hasRetried = err.requestOptions.extra['retried'] == true;
      if (hasRetried) return handler.next(err);

      if (_refreshCompleter != null) {
        if (kDebugMode) debugPrint('AuthInterceptor: awaiting in-flight refresh');
        final newToken = await _refreshCompleter!.future;
        if (newToken != null) {
          return _retryWithToken(err, handler, newToken);
        }
        return handler.next(err);
      }

      _refreshCompleter = Completer<String?>();
      if (kDebugMode) debugPrint('AuthInterceptor: triggering refresh');
      final newToken = await DioFactory.refreshToken();
      _refreshCompleter?.complete(newToken);
      _refreshCompleter = null;

      if (newToken != null) {
        return _retryWithToken(err, handler, newToken);
      }
      return handler.next(err);
    } catch (_) {
      _refreshCompleter?.complete(null);
      _refreshCompleter = null;
      return handler.next(err);
    }
  }

  Future<void> _retryWithToken(
    DioException err,
    ErrorInterceptorHandler handler,
    String newToken,
  ) async {
    final requestOptions = err.requestOptions;
    requestOptions.headers['Authorization'] = 'Bearer $newToken';
    requestOptions.extra['retried'] = true;
    try {
      final dio = DioFactory.sharedDio;
      final response = await dio.fetch(requestOptions);
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }
}


