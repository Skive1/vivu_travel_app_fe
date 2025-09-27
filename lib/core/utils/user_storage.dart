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
      
      await _storage.write(
        key: _userKey,
        value: jsonEncode(userJson),
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user profile
  static Future<UserEntity?> getUserProfile() async {
    try {
      final userJsonString = await _storage.read(key: _userKey);
      if (userJsonString == null) return null;
      
      final userJson = jsonDecode(userJsonString) as Map<String, dynamic>;
      
      return UserEntity(
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
    } catch (e) {
      return null;
    }
  }

  // Clear user profile
  static Future<void> clearUserProfile() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (e) {
    }
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
