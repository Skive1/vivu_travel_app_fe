import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String dateOfBirth;
  final String name;
  final String address;
  final String phoneNumber;
  final String avatarUrl;
  final String gender;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.gender,
  });

  @override
  List<Object> get props => [email, password, dateOfBirth, name, address, phoneNumber, avatarUrl, gender];
}

class VerifyRegisterOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;

  const VerifyRegisterOtpRequested({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, otpCode];
}

class LogoutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}
