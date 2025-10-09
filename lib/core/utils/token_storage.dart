import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_decoder.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // In-memory caches to avoid repeated secure storage reads on hot paths
  static String? _cachedToken;
  static String? _cachedRefreshToken;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';

  // Enhanced token saving with validation
  static Future<bool> saveToken(String token) async {
    try {
      // Validate token structure first
      if (!JwtDecoder.isValidTokenStructure(token)) {
        throw Exception('Invalid token structure');
      }

      // Extract user info from JWT first
      final userId = JwtDecoder.getUserId(token);
      final userName = JwtDecoder.getUserName(token);
      final userEmail = JwtDecoder.getUserEmail(token);
      
      // Batch ALL storage operations for maximum performance
      final allWrites = <Future<void>>[
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _loginTimeKey, value: DateTime.now().toIso8601String()),
      ];
      
      // Add conditional writes
      if (userId != null) allWrites.add(_storage.write(key: _userIdKey, value: userId));
      if (userName != null) allWrites.add(_storage.write(key: _userNameKey, value: userName));
      if (userEmail != null) allWrites.add(_storage.write(key: _userEmailKey, value: userEmail));
      
      // Execute all writes in parallel
      await Future.wait(allWrites);

      // Update in-memory cache
      _cachedToken = token;

      return true;
    } catch (e) {
      // If save fails, clear any partial data
      await clearAll();
      return false;
    }
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final t = await _storage.read(key: _tokenKey);
    _cachedToken = t;
    return t;
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    _cachedRefreshToken = refreshToken;
  }
  
  // Batch save both tokens for login optimization
  static Future<bool> saveBothTokens(String accessToken, String refreshToken) async {
    try {
      // Validate token structure first
      if (!JwtDecoder.isValidTokenStructure(accessToken)) {
        throw Exception('Invalid token structure');
      }

      // Extract user info from JWT
      final userId = JwtDecoder.getUserId(accessToken);
      final userName = JwtDecoder.getUserName(accessToken);
      final userEmail = JwtDecoder.getUserEmail(accessToken);
      
      // Batch ALL storage operations for maximum performance
      final allWrites = <Future<void>>[
        _storage.write(key: _tokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
        _storage.write(key: _loginTimeKey, value: DateTime.now().toIso8601String()),
      ];
      
      // Add conditional writes
      if (userId != null) allWrites.add(_storage.write(key: _userIdKey, value: userId));
      if (userName != null) allWrites.add(_storage.write(key: _userNameKey, value: userName));
      if (userEmail != null) allWrites.add(_storage.write(key: _userEmailKey, value: userEmail));
      
      // Execute all writes in parallel
      await Future.wait(allWrites);
      
      // Update in-memory caches
      _cachedToken = accessToken;
      _cachedRefreshToken = refreshToken;

      return true;
    } catch (e) {
      // If save fails, clear any partial data
      await clearAll();
      return false;
    }
  }

  static Future<String?> getRefreshToken() async {
    if (_cachedRefreshToken != null) return _cachedRefreshToken;
    final t = await _storage.read(key: _refreshTokenKey);
    _cachedRefreshToken = t;
    return t;
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  static Future<DateTime?> getLoginTime() async {
    final timeString = await _storage.read(key: _loginTimeKey);
    if (timeString == null) return null;
    
    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }

  // Clear methods
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<void> clearRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    _cachedToken = null;
    _cachedRefreshToken = null;
  }

  // Enhanced validation methods
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    
    // Check structure validity
    if (!JwtDecoder.isValidTokenStructure(token)) {
      await clearAll(); // Clear invalid token
      return false;
    }
    
    // Check expiry
    if (JwtDecoder.isExpired(token)) {
      await clearAll(); // Clear expired token
      return false;
    }
    
    return true;
  }

  // Get token expiry info
  static Future<Duration?> getTokenTimeRemaining() async {
    final token = await getToken();
    if (token == null) return null;
    
    return JwtDecoder.getTimeUntilExpiry(token);
  }

  static Future<bool> isTokenNearExpiry({Duration threshold = const Duration(minutes: 10)}) async {
    final timeRemaining = await getTokenTimeRemaining();
    if (timeRemaining == null) return true;
    
    return timeRemaining <= threshold;
  }
}
