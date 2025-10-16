import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_decoder.dart';
import '../network/dio_factory.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // In-memory caches for hot paths
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;
  static DateTime? _cachedAccessExpiry;

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _loginTimeKey = 'login_time';
  static const String _accessExpKey = 'access_expiry';

  // Init must be called once on app start to warm caches
  static Future<void> init() async {
    final reads = await Future.wait<String?>([
      _storage.read(key: _tokenKey),
      _storage.read(key: _refreshTokenKey),
      _storage.read(key: _accessExpKey),
    ]);
    _cachedAccessToken = reads[0];
    _cachedRefreshToken = reads[1];
    final expIso = reads[2];
    if (expIso != null) {
      try {
        _cachedAccessExpiry = DateTime.parse(expIso);
      } catch (_) {
        _cachedAccessExpiry = null;
      }
    }
  }

  // Synchronous getters for hot paths
  static String? get accessTokenSync => _cachedAccessToken;
  static String? get refreshTokenSync => _cachedRefreshToken;
  static DateTime? get accessExpirySync => _cachedAccessExpiry;

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
      // Derive expiry once and cache
      final remaining = JwtDecoder.getTimeUntilExpiry(token);
      final expiry = remaining != null ? DateTime.now().add(remaining) : null;
      
      // Batch ALL storage operations for maximum performance
      final allWrites = <Future<void>>[
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _loginTimeKey, value: DateTime.now().toIso8601String()),
      ];
      if (expiry != null) {
        allWrites.add(_storage.write(key: _accessExpKey, value: expiry.toIso8601String()));
      }
      
      // Add conditional writes
      if (userId != null) allWrites.add(_storage.write(key: _userIdKey, value: userId));
      if (userName != null) allWrites.add(_storage.write(key: _userNameKey, value: userName));
      if (userEmail != null) allWrites.add(_storage.write(key: _userEmailKey, value: userEmail));
      
      // Execute all writes in parallel
      await Future.wait(allWrites);

      // Update in-memory cache
      _cachedAccessToken = token;
      _cachedAccessExpiry = expiry;

      return true;
    } catch (e) {
      // If save fails, clear any partial data
      await clearAuthData();
      return false;
    }
  }

  static Future<String?> getToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;
    final t = await _storage.read(key: _tokenKey);
    _cachedAccessToken = t;
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
      final remaining = JwtDecoder.getTimeUntilExpiry(accessToken);
      final expiry = remaining != null ? DateTime.now().add(remaining) : null;
      
      // Batch ALL storage operations for maximum performance
      final allWrites = <Future<void>>[
        _storage.write(key: _tokenKey, value: accessToken),
        _storage.write(key: _loginTimeKey, value: DateTime.now().toIso8601String()),
      ];
      if (expiry != null) {
        allWrites.add(_storage.write(key: _accessExpKey, value: expiry.toIso8601String()));
      }
      
      // Only save refresh token if it's valid (not null/empty)
      if (refreshToken.isNotEmpty) {
        allWrites.add(_storage.write(key: _refreshTokenKey, value: refreshToken));
      }
      
      // Add conditional writes
      if (userId != null) allWrites.add(_storage.write(key: _userIdKey, value: userId));
      if (userName != null) allWrites.add(_storage.write(key: _userNameKey, value: userName));
      if (userEmail != null) allWrites.add(_storage.write(key: _userEmailKey, value: userEmail));
      
      // Execute all writes in parallel
      await Future.wait(allWrites);
      
      // Update in-memory caches
      _cachedAccessToken = accessToken;
      _cachedAccessExpiry = expiry;
      if (refreshToken.isNotEmpty) {
        _cachedRefreshToken = refreshToken;
      }

      return true;
    } catch (e) {
      // If save fails, clear any partial data
      await clearAuthData();
      return false;
    }
  }

  // Secure refresh token rotation - only save refresh token if valid
  static Future<bool> saveBothTokensSecure(String accessToken, String? refreshToken) async {
    try {
      // Validate token structure first
      if (!JwtDecoder.isValidTokenStructure(accessToken)) {
        throw Exception('Invalid token structure');
      }

      // Extract user info from JWT
      final userId = JwtDecoder.getUserId(accessToken);
      final userName = JwtDecoder.getUserName(accessToken);
      final userEmail = JwtDecoder.getUserEmail(accessToken);
      final remaining = JwtDecoder.getTimeUntilExpiry(accessToken);
      final expiry = remaining != null ? DateTime.now().add(remaining) : null;
      
      // Batch ALL storage operations for maximum performance
      final allWrites = <Future<void>>[
        _storage.write(key: _tokenKey, value: accessToken),
        _storage.write(key: _loginTimeKey, value: DateTime.now().toIso8601String()),
      ];
      if (expiry != null) {
        allWrites.add(_storage.write(key: _accessExpKey, value: expiry.toIso8601String()));
      }
      
      // Only save refresh token if it's valid (not null/empty)
      if (refreshToken != null && refreshToken.isNotEmpty) {
        allWrites.add(_storage.write(key: _refreshTokenKey, value: refreshToken));
      }
      
      // Add conditional writes
      if (userId != null) allWrites.add(_storage.write(key: _userIdKey, value: userId));
      if (userName != null) allWrites.add(_storage.write(key: _userNameKey, value: userName));
      if (userEmail != null) allWrites.add(_storage.write(key: _userEmailKey, value: userEmail));
      
      // Execute all writes in parallel
      await Future.wait(allWrites);
      
      // Update in-memory caches
      _cachedAccessToken = accessToken;
      _cachedAccessExpiry = expiry;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        _cachedRefreshToken = refreshToken;
      }

      return true;
    } catch (e) {
      // If save fails, clear any partial data
      await clearAuthData();
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
    await _storage.delete(key: _accessExpKey);
    _cachedAccessToken = null; // Clear in-memory cache
    _cachedAccessExpiry = null;
  }

  static Future<void> clearRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
    _cachedRefreshToken = null; // Clear in-memory cache
  }

  static Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _accessExpKey),
    ]);
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedAccessExpiry = null;
    DioFactory.clearRefreshLock();
  }

  // Enhanced validation methods
  static Future<bool> hasToken() async {
    final token = _cachedAccessToken ?? await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isTokenValid() async {
    final token = _cachedAccessToken ?? await getToken();
    if (token == null || token.isEmpty) return false;
    final exp = _cachedAccessExpiry;
    if (exp == null) return false;
    return DateTime.now().isBefore(exp);
  }

  // Get token expiry info
  static Future<Duration?> getTokenTimeRemaining() async {
    final exp = _cachedAccessExpiry;
    if (exp == null) return null;
    final now = DateTime.now();
    if (now.isAfter(exp)) return Duration.zero;
    return exp.difference(now);
  }

  static Future<bool> isTokenNearExpiry({
    Duration threshold = const Duration(minutes: 3),
    Duration skew = const Duration(seconds: 90),
  }) async {
    final exp = _cachedAccessExpiry;
    if (exp == null) return true;
    final now = DateTime.now();
    final remaining = exp.difference(now);
    return remaining <= (threshold + skew);
  }
}
