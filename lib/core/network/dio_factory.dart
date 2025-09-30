import 'package:dio/dio.dart';
import 'endpoints.dart';
import 'api_config.dart';
import '../utils/token_storage.dart';
import 'network_info.dart';
import '../../injection_container.dart' as di;

class DioFactory {
  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: Duration(milliseconds: NetworkConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: NetworkConfig.receiveTimeout),
      headers: NetworkConfig.defaultHeaders,
    ));

    // Network Check & Token Interceptor with Refresh Logic
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check network connectivity first
          final networkInfo = di.sl<NetworkInfo>();
          if (!await networkInfo.isConnected) {
            return handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
                message: 'No internet connection',
              ),
            );
          }

          // Add auth token if available
          final token = await TokenStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            
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

              final newToken = await _refreshToken(dio);
              if (newToken != null) {
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                requestOptions.extra['retried'] = true;
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

      // Call refresh endpoint with refreshToken as query param
      final response = await dio.get(
        '${Endpoints.refreshToken}?refreshToken=$refreshToken',
        options: Options(headers: {
          // Ensure we don't send stale access token while refreshing
          'Authorization': null,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        
        // Batch save tokens for better performance
        await Future.wait([
          TokenStorage.saveToken(newAccessToken),
          TokenStorage.saveRefreshToken(newRefreshToken),
        ]);
        
        return newAccessToken;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}