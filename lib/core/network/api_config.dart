import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_config.dart';

class NetworkConfig {
  static String get baseUrl {
    final envUrl = dotenv.env['BASE_URL']!;

    return envUrl;
  }
  
  static int get connectTimeout => AppConfig.apiConnectTimeout;
  static int get receiveTimeout => AppConfig.apiReceiveTimeout;
  static int get sendTimeout => AppConfig.apiSendTimeout;

  static Map<String, String> get defaultHeaders => ApiConfig.defaultHeaders;
}