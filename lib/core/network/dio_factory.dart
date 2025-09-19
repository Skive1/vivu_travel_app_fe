import 'package:dio/dio.dart';
import 'api_config.dart';
import '../utils/token_storage.dart';

class DioFactory {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.defaultHeaders,
    ));

    // Token Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Tự động thêm token vào header nếu có
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Xử lý refresh token nếu 401
          if (error.response?.statusCode == 401) {
            // TODO: Implement token refresh logic
            await TokenStorage.clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Logging Interceptor
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ));

    return dio;
  }
}
