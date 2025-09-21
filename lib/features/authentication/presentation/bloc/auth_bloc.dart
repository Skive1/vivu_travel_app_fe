import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_register_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyRegisterOtpUseCase verifyRegisterOtpUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.refreshTokenUseCase,
    required this.registerUseCase,
    required this.verifyRegisterOtpUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyRegisterOtpRequested>(_onVerifyRegisterOtpRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authEntity) => emit(AuthAuthenticated(authEntity)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthStatusUseCase(NoParams());

    result.fold(
      (failure) {
        // Token hết hạn hoặc không có token
        emit(const AuthUnauthenticated());
      },
      (authEntity) {
        // Token còn hạn
        emit(AuthAuthenticated(authEntity));
      },
    );
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await refreshTokenUseCase(NoParams());

    result.fold(
      (failure) {
        // Refresh failed - force logout
        emit(const AuthUnauthenticated('Session expired. Please login again.'));
      },
      (newToken) {
        // Token refreshed successfully - check auth status to get updated entity
        add(AuthStatusChecked());
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        dateOfBirth: event.dateOfBirth,
        name: event.name,
        address: event.address,
        phoneNumber: event.phoneNumber,
        avatarUrl: event.avatarUrl,
        gender: event.gender,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (message) => emit(RegisterSuccess(message: message, email: event.email)),
    );
  }

  Future<void> _onVerifyRegisterOtpRequested(
    VerifyRegisterOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyRegisterOtpUseCase(
      VerifyRegisterOtpParams(
        email: event.email,
        otpCode: event.otpCode,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (message) => emit(OtpVerificationSuccess(message)),
    );
  }
}
