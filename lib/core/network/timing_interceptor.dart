import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TimingInterceptor extends Interceptor {
  static const String _kStartTimeKey = '__start_time__';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_kStartTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logDuration(response.requestOptions, response.statusCode);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logDuration(err.requestOptions, err.response?.statusCode);
    handler.next(err);
  }

  void _logDuration(RequestOptions options, int? statusCode) {
    final start = options.extra[_kStartTimeKey] as int?;
    if (start == null) return;
    final elapsed = DateTime.now().millisecondsSinceEpoch - start;
    if (kDebugMode) {
      debugPrint('[NET] ${options.method} ${options.uri} ${statusCode ?? ''} in ${elapsed}ms');
    }
  }
}


