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

    // Token Interceptor with Refresh Logic
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            
            if (requestOptions.path.contains('/refresh_token')) {
              await TokenStorage.clearAll();
              return handler.reject(error);
            }
            
            try {
              final newToken = await _refreshToken(dio);
              if (newToken != null) {
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryResponse = await dio.fetch(requestOptions);
                return handler.resolve(retryResponse);
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

  static Future<String?> _refreshToken(Dio dio) async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $refreshToken',
        },
      ));

      final response = await refreshDio.get('/refresh_token');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        
        await TokenStorage.saveToken(newAccessToken);
        await TokenStorage.saveRefreshToken(newRefreshToken);
        
        return newAccessToken;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
