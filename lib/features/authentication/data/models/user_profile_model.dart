import '../../domain/entities/user_entity.dart';

class GetUserResponseModel {
  final String id;
  final String email;
  final bool isActive;
  final String roleName;
  final UserProfileModel profile;

  const GetUserResponseModel({
    required this.id,
    required this.email,
    required this.isActive,
    required this.roleName,
    required this.profile,
  });

  factory GetUserResponseModel.fromJson(Map<String, dynamic> json) {
    return GetUserResponseModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      isActive: json['isActive'] ?? false,
      roleName: json['roleName'] ?? '',
      profile: UserProfileModel.fromJson(json['profile'] ?? {}),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: profile.name,
      avatar: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : null,
      createdAt: DateTime.tryParse(profile.dateOfBirth),
      isActive: isActive,
      roleName: roleName,
      dateOfBirth: profile.dateOfBirth,
      address: profile.address,
      phoneNumber: profile.phoneNumber,
      gender: profile.gender,
    );
  }
}

class UserProfileModel {
  final String dateOfBirth;
  final String name;
  final String address;
  final String phoneNumber;
  final String avatarUrl;
  final String gender;

  const UserProfileModel({
    required this.dateOfBirth,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.gender,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      dateOfBirth: json['dateOfBirth'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'gender': gender,
    };
  }
}
