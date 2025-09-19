import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'jwt_decoder.dart';

class TokenStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  // Token methods
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    
    // Extract and save user info from JWT
    final userId = JwtDecoder.getUserId(token);
    final userName = JwtDecoder.getUserName(token);
    final userEmail = JwtDecoder.getUserEmail(token);
    
    if (userId != null) await _storage.write(key: _userIdKey, value: userId);
    if (userName != null) await _storage.write(key: _userNameKey, value: userName);
    if (userEmail != null) await _storage.write(key: _userEmailKey, value: userEmail);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: _userNameKey, value: userName);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<void> saveUserEmail(String userEmail) async {
    await _storage.write(key: _userEmailKey, value: userEmail);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
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
  }

  // Check methods
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    
    return !JwtDecoder.isExpired(token);
  }
}
