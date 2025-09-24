import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/reset_token_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthEntity authEntity;

  const AuthAuthenticated(this.authEntity);

  @override
  List<Object> get props => [authEntity];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class RegisterSuccess extends AuthState {
  final String message;
  final String email;

  const RegisterSuccess({
    required this.message,
    required this.email,
  });

  @override
  List<Object> get props => [message, email];
}

class OtpVerificationSuccess extends AuthState {
  final String message;

  const OtpVerificationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

// Forgot Password States
class PasswordResetRequestSuccess extends AuthState {
  final String message;
  final String email;

  const PasswordResetRequestSuccess({
    required this.message,
    required this.email,
  });

  @override
  List<Object> get props => [message, email];
}

class ResetPasswordOtpVerificationSuccess extends AuthState {
  final ResetTokenEntity resetTokenEntity;

  const ResetPasswordOtpVerificationSuccess(this.resetTokenEntity);

  @override
  List<Object> get props => [resetTokenEntity];
}

class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ResendRegisterOtpSuccess extends AuthState {
  final String message;

  const ResendRegisterOtpSuccess(this.message);

  @override
  List<Object> get props => [message];
}
