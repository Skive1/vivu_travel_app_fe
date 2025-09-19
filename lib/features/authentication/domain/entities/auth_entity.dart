import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String token;
  final String userName;
  final DateTime expiresAt;

  const AuthEntity({
    required this.token,
    required this.userName,
    required this.expiresAt,
  });

  @override
  List<Object> get props => [token, userName, expiresAt];
}