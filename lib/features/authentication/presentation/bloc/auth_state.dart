import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_entity.dart';

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
