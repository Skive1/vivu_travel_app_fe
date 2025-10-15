import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/authentication/domain/entities/user_entity.dart';

class UserStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _userKey = 'user_profile';
  static const String _userCacheTimeKey = 'user_cache_time';
  static const String _scheduleRolePrefix = 'schedule_role_';
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache for 24 hours

  // In-memory cache to avoid repeated secure storage reads and JSON parsing
  static UserEntity? _cachedUser;
  static DateTime? _cachedAt;

  // Save user profile
  static Future<bool> saveUserProfile(UserEntity user) async {
    try {
      final userJson = {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'avatar': user.avatar,
        'createdAt': user.createdAt?.toIso8601String(),
        'isActive': user.isActive,
        'roleName': user.roleName,
        'dateOfBirth': user.dateOfBirth,
        'address': user.address,
        'phoneNumber': user.phoneNumber,
        'gender': user.gender,
      };
      
      // Save user data and cache timestamp
      await Future.wait([
        _storage.write(key: _userKey, value: jsonEncode(userJson)),
        _storage.write(key: _userCacheTimeKey, value: DateTime.now().toIso8601String()),
      ]);
      // Update in-memory cache
      _cachedUser = user;
      _cachedAt = DateTime.now();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  static Future<UserEntity?> getUserProfile() async {
    try {
      // Serve from memory cache if valid
      if (_cachedUser != null && _cachedAt != null) {
        if (DateTime.now().difference(_cachedAt!) <= _cacheExpiry) {
          return _cachedUser;
        }
      }

      // Check if persistent cache is expired
      final cacheTimeString = await _storage.read(key: _userCacheTimeKey);
      if (cacheTimeString != null) {
        final cacheTime = DateTime.parse(cacheTimeString);
        if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
          // Cache expired, clear it
          await clearUserProfile();
          return null;
        }
      }

      final userJsonString = await _storage.read(key: _userKey);
      if (userJsonString == null) return null;
      
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      
      final user = UserEntity(
        id: userJson['id'] ?? '',
        email: userJson['email'] ?? '',
        name: userJson['name'] ?? '',
        avatar: userJson['avatar'],
        createdAt: userJson['createdAt'] != null 
            ? DateTime.tryParse(userJson['createdAt'])
            : null,
        isActive: userJson['isActive'] ?? false,
        roleName: userJson['roleName'] ?? '',
        dateOfBirth: userJson['dateOfBirth'] ?? '',
        address: userJson['address'] ?? '',
        phoneNumber: userJson['phoneNumber'] ?? '',
        gender: userJson['gender'] ?? '',
      );
      _cachedUser = user;
      _cachedAt = DateTime.now();
      return user;
    } catch (e) {
      return null;
    }
  }

  // Clear user profile
  static Future<void> clearUserProfile() async {
      await Future.wait([
        _storage.delete(key: _userKey),
        _storage.delete(key: _userCacheTimeKey),
      ]);
      _cachedUser = null;
      _cachedAt = null;
  }

  // ----- Schedule role cache -----
  static Future<void> setScheduleRole({required String scheduleId, required String role}) async {
    try {
      await _storage.write(key: _scheduleRolePrefix + scheduleId, value: role);
    } catch (_) {}
  }

  static Future<String?> getScheduleRole(String scheduleId) async {
    try {
      return await _storage.read(key: _scheduleRolePrefix + scheduleId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> removeScheduleRole(String scheduleId) async {
    try {
      await _storage.delete(key: _scheduleRolePrefix + scheduleId);
    } catch (_) {}
  }

  // Check if user profile exists
  static Future<bool> hasUserProfile() async {
    try {
      final userJsonString = await _storage.read(key: _userKey);
      return userJsonString != null;
    } catch (e) {
      return false;
    }
  }
}
