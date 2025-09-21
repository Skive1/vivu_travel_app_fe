import '../../domain/entities/auth_entity.dart';

class LoginResponseModel {
  final String token;
  final String userName;
  final String expiresAt;
  final String refreshToken;

  const LoginResponseModel({
    required this.token,
    required this.userName,
    required this.expiresAt,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] ?? '',
      userName: json['userName'] ?? '',
      expiresAt: json['expiresAt'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
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