import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/user_storage.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/refresh_token_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_register_otp_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/verify_reset_password_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/resend_register_otp_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
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
  final ResendRegisterOtpUseCase resendRegisterOtpUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final VerifyResetPasswordOtpUseCase verifyResetPasswordOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.refreshTokenUseCase,
    required this.registerUseCase,
    required this.verifyRegisterOtpUseCase,
    required this.resendRegisterOtpUseCase,
    required this.requestPasswordResetUseCase,
    required this.verifyResetPasswordOtpUseCase,
    required this.resetPasswordUseCase,
    required this.getUserProfileUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyRegisterOtpRequested>(_onVerifyRegisterOtpRequested);
    on<ResendRegisterOtpRequested>(_onResendRegisterOtpRequested);
    on<RequestPasswordResetRequested>(_onRequestPasswordResetRequested);
    on<VerifyResetPasswordOtpRequested>(_onVerifyResetPasswordOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<GetUserProfileRequested>(_onGetUserProfileRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        debugPrint('🔴 Login failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (authEntity) async {
        debugPrint('🟢 Login successful, getting user profile...');
        
        // Load cached user profile first for faster UI
        final cachedUser = await UserStorage.getUserProfile();
        debugPrint('📦 Cached user: ${cachedUser?.name ?? "No cached user"}');
        
        // Emit authenticated state with cached profile (if available)
        if (!emit.isDone) {
          emit(AuthAuthenticated(authEntity, userEntity: cachedUser));
          debugPrint('✅ Emitted AuthAuthenticated with cached user');
        }
        
        // Then get fresh user profile from API
        debugPrint('🔄 Requesting fresh user profile...');
        add(GetUserProfileRequested());
      },
    );
  }

  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('🔍 Getting user profile...');
    
    // Only proceed if we're currently authenticated
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      debugPrint('🔴 Not authenticated, cannot get user profile');
      return;
    }

    final result = await getUserProfileUseCase(NoParams());

    await result.fold(
      (failure) async {
        debugPrint('🔴 Failed to get user profile: ${failure.message}');
        // If getting user profile fails, we still keep them authenticated
        // but without user profile data
      },
      (userEntity) async {
        debugPrint('🟢 User profile received: ${userEntity.name} (${userEntity.email})');
        
        // Save user profile to storage for future fast loading
        final saved = await UserStorage.saveUserProfile(userEntity);
        debugPrint('💾 User profile saved to storage: $saved');
        
        // Update authenticated state with fresh user profile
        if (!emit.isDone) {
          emit(currentState.copyWith(userEntity: userEntity));
          debugPrint('✅ Emitted updated AuthAuthenticated with fresh user profile');
        }
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    await result.fold(
      (failure) async => emit(AuthError(failure.message)),
      (_) async {
        // Clear user profile from storage
        await UserStorage.clearUserProfile();
        
        // Check if emit is still available before calling
        if (!emit.isDone) {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthStatusUseCase(NoParams());

    await result.fold(
      (failure) async {
        // Token hết hạn hoặc không có token - clear user profile
        await UserStorage.clearUserProfile();
        if (!emit.isDone) {
          emit(const AuthUnauthenticated());
        }
      },
      (authEntity) async {
        // Token còn hạn - load cached profile first
        final cachedUser = await UserStorage.getUserProfile();
        
        // Emit authenticated state with cached profile
        if (!emit.isDone) {
          emit(AuthAuthenticated(authEntity, userEntity: cachedUser));
        }
        
        // Then get fresh user profile from API
        add(GetUserProfileRequested());
      },
    );
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await refreshTokenUseCase(NoParams());

    await result.fold(
      (failure) async {
        // Refresh failed - force logout and clear user profile
        await UserStorage.clearUserProfile();
        if (!emit.isDone) {
          emit(const AuthUnauthenticated('Session expired. Please login again.'));
        }
      },
      (newToken) async {
        // Token refreshed successfully - check auth status and refresh user profile
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

  Future<void> _onResendRegisterOtpRequested(
    ResendRegisterOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await resendRegisterOtpUseCase(
      ResendRegisterOtpParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (message) => emit(ResendRegisterOtpSuccess(message)),
    );
  }

  Future<void> _onRequestPasswordResetRequested(
    RequestPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await requestPasswordResetUseCase(
      RequestPasswordResetParams(email: event.email),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (message) => emit(PasswordResetRequestSuccess(message: message, email: event.email)),
    );
  }

  Future<void> _onVerifyResetPasswordOtpRequested(
    VerifyResetPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyResetPasswordOtpUseCase(
      VerifyResetPasswordOtpParams(
        email: event.email,
        otpCode: event.otpCode,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (resetTokenEntity) => emit(ResetPasswordOtpVerificationSuccess(resetTokenEntity)),
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        resetToken: event.resetToken,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (message) => emit(PasswordResetSuccess(message)),
    );
  }
}
