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

class ResendRegisterOtpRequested extends AuthEvent {
  final String email;

  const ResendRegisterOtpRequested({required this.email});

  @override
  List<Object> get props => [email];
}

// Forgot Password Events
class RequestPasswordResetRequested extends AuthEvent {
  final String email;

  const RequestPasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyResetPasswordOtpRequested extends AuthEvent {
  final String email;
  final String otpCode;

  const VerifyResetPasswordOtpRequested({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, otpCode];
}

class ResetPasswordRequested extends AuthEvent {
  final String resetToken;
  final String newPassword;

  const ResetPasswordRequested({
    required this.resetToken,
    required this.newPassword,
  });

  @override
  List<Object> get props => [resetToken, newPassword];
}

class LogoutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}

class GetUserProfileRequested extends AuthEvent {}
