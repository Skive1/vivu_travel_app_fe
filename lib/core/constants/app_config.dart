
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Base URL Configuration
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://143.198.203.34:5120';
  static String get signalR => dotenv.env['WEBSOCKET_URL'] ?? 'http://143.198.203.34:5003';
  static String get signalRUrl => '$signalR/notificationHub';
  
  // API Configuration
  static const int apiConnectTimeout = 5000; // 5 seconds
  static const int apiReceiveTimeout = 12000; // 12 seconds (mobile-friendly)
  static const int apiSendTimeout = 5000; // 5 seconds
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 10);
  
  // Token Configuration
  static const Duration tokenRefreshThreshold = Duration(minutes: 10);
  static const Duration tokenExpiryBuffer = Duration(minutes: 5);
  static const Duration maxTokenAge = Duration(days: 7);
  
  // Cache Configuration
  static const Duration userProfileCacheExpiry = Duration(hours: 24);
  static const Duration authTokenCacheExpiry = Duration(hours: 1);
  static const Duration generalCacheExpiry = Duration(minutes: 30);
  
  // UI Configuration
  static const Duration splashScreenDuration = Duration(milliseconds: 2000);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration debounceDelay = Duration(milliseconds: 500);
  
  // Validation Configuration
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
  static const int otpLength = 6;
  static const int maxAddressLength = 200;
  
  // OTP Configuration
  static const Duration otpResendCooldown = Duration(seconds: 60);
  static const Duration otpExpiryTime = Duration(minutes: 5);
  static const int maxOtpAttempts = 3;
  
  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];
  
  // Network Configuration
  static const Duration networkCheckInterval = Duration(seconds: 30);
  static const Duration offlineRetryDelay = Duration(seconds: 5);
  
  // Security Configuration
  static const int maxLoginAttempts = 5;
  static const Duration loginLockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 24);
  
  // Performance Configuration
  static const int maxConcurrentRequests = 5;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const bool enableRequestLogging = true;
  static const bool enablePerformanceMonitoring = true;
  
  // Feature Flags
  static const bool enableBiometricAuth = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableDebugMode = false;
}

/// API Endpoint configuration
class ApiConfig {

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'VivuTravel-Mobile/1.0.0',
  };
  
  static Map<String, String> get authHeaders => {
    ...defaultHeaders,
    'Authorization': 'Bearer {token}', // Will be replaced with actual token
  };
}
