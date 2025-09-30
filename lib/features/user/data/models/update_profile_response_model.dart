import '../../../authentication/domain/entities/user_entity.dart';

class UpdateProfileResponseModel {
  final String id;
  final String dateOfBirth;
  final String name;
  final String address;
  final String phoneNumber;
  final String avatarUrl;
  final String gender;

  UpdateProfileResponseModel({
    required this.id,
    required this.dateOfBirth,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.gender,
  });

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseModel(
      id: json['id'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      gender: json['gender'] ?? '',
    );
  }

  UserEntity toEntity(UserEntity previousUser) {
    return UserEntity(
      id: id.isNotEmpty ? id : previousUser.id,
      email: previousUser.email,
      name: name.isNotEmpty ? name : previousUser.name,
      avatar: avatarUrl.isNotEmpty ? avatarUrl : previousUser.avatar,
      createdAt: previousUser.createdAt,
      isActive: previousUser.isActive,
      roleName: previousUser.roleName,
      dateOfBirth: dateOfBirth.isNotEmpty ? dateOfBirth : previousUser.dateOfBirth,
      address: address.isNotEmpty ? address : previousUser.address,
      phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : previousUser.phoneNumber,
      gender: gender.isNotEmpty ? gender : previousUser.gender,
    );
  }
}


