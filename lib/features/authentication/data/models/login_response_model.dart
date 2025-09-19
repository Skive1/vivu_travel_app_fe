import '../../domain/entities/auth_entity.dart';

class LoginResponseModel {
  final String token;
  final String userName;
  final String expiresAt;

  const LoginResponseModel({
    required this.token,
    required this.userName,
    required this.expiresAt,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      userName: json['userName'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      token: token,
      userName: userName,
      expiresAt: DateTime.tryParse(expiresAt) ?? DateTime.now(),
    );
  }
}