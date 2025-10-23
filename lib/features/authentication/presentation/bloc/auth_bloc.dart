import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';
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
  final ChangePasswordUseCase changePasswordUseCase;
  final AuthRepository authRepository;
  final NotificationBloc? notificationBloc;

  bool _isFetchingProfile = false; // prevent duplicate /auth/me calls

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
    required this.changePasswordUseCase,
    required this.authRepository,
    this.notificationBloc,
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
    on<ChangePasswordRequested>(_onChangePasswordRequested);
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
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Login Failed'));
        }
      },
      (authEntity) async {

        // 1) Load cached profile quickly and emit immediately for fast UI paint
        final cachedUser = await UserStorage.getUserProfile();
        if (!emit.isDone) {
          emit(AuthAuthenticated(authEntity, userEntity: cachedUser));
        }

        // 2) Initialize SignalR for real-time notifications
        _initializeSignalRForAuthenticatedUser(cachedUser);

        // 3) Then trigger fresh user profile load in background to update UI
        if (!isClosed) {
          add(GetUserProfileRequested());
        }
      },
    );
  }


  Future<void> _onGetUserProfileRequested(
    GetUserProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    
    // Only proceed if we're currently authenticated
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return;
    }

    if (_isFetchingProfile) {
      return; // drop duplicate while in-flight
    }

    _isFetchingProfile = true;
    try {
      final result = await getUserProfileUseCase(NoParams());

      await result.fold(
        (failure) async {
          // Keep authenticated state; optionally log failure
        },
        (userEntity) async {
          await UserStorage.saveUserProfile(userEntity);
          if (!emit.isDone) {
            emit(currentState.copyWith(userEntity: userEntity));
          }
          
          // Trigger SignalR initialization now that we have userEntity
          print('🔄 AuthBloc: User profile loaded, triggering SignalR initialization...');
          _initializeSignalRForAuthenticatedUser(userEntity);
        },
      );
    } finally {
      _isFetchingProfile = false;
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase(NoParams());

    await result.fold(
      (failure) async {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Logout Failed'));
        }
      },
      (_) async {
        // Clear user profile from storage
        await UserStorage.clearUserProfile();
        
        // Stop SignalR connection when user logs out
        _stopSignalRConnection();
        
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
        
        // Initialize SignalR for real-time notifications
        _initializeSignalRForAuthenticatedUser(cachedUser);
        
        // Then get fresh user profile from API
        if (!isClosed) {
          add(GetUserProfileRequested());
        }
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
        if (!isClosed) {
          add(AuthStatusChecked());
        }
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
        gender: event.gender,
      ),
    );

        result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Register Failed'));
        }
      },
      (message) {
        if (!emit.isDone) {
          emit(RegisterSuccess(message: message, email: event.email));
        }
      },
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
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'OTP Verification Failed'));
        }
      },
      (message) {
        if (!emit.isDone) {
          emit(OtpVerificationSuccess(message));
        }
      },
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
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Resend OTP Failed'));
        }
      },
      (message) {
        if (!emit.isDone) {
          emit(ResendRegisterOtpSuccess(message));
        }
      },
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
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Password Reset Request Failed'));
        }
      },
      (message) {
        if (!emit.isDone) {
          emit(PasswordResetRequestSuccess(message: message, email: event.email));
        }
      },
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
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'OTP Verification Failed'));
        }
      },
      (resetTokenEntity) {
        if (!emit.isDone) {
          emit(ResetPasswordOtpVerificationSuccess(resetTokenEntity));
        }
      },
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
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Reset Password Failed'));
        }
      },
      (message) {
        if (!emit.isDone) {
          emit(PasswordResetSuccess(message));
        }
      },
    );
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await changePasswordUseCase(
      ChangePasswordParams(
        oldPassword: event.oldPassword,
        newPassword: event.newPassword,
      ),
    );

    result.fold(
      (failure) {
        if (!emit.isDone) {
          emit(AuthError(failure.message, title: 'Change Password Failed'));
        }
      },
      (changePasswordEntity) {
        if (!emit.isDone) {
          emit(ChangePasswordSuccess(changePasswordEntity.message));
        }
      },
    );
  }

  // SignalR helper methods
  void _initializeSignalRForAuthenticatedUser(dynamic userEntity) {
    if (notificationBloc == null) return;
    
    try {
      print('🔌 AuthBloc: Starting SignalR initialization for authenticated user...');
      
      // Get userId from current AuthBloc state (same as Header avatar)
      final currentState = state;
      String? userId;
      
      if (currentState is AuthAuthenticated) {
        // Get userId from state.userEntity (same source as Header avatar)
        if (currentState.hasUserProfile && currentState.userEntity != null) {
          userId = currentState.userEntity!.id;
          print('🔍 AuthBloc: Got userId from state.userEntity: $userId');
        }
        
        // Fallback to parameter userEntity if state doesn't have userEntity yet
        if (userId == null && userEntity != null && userEntity.id != null) {
          userId = userEntity.id;
          print('🔍 AuthBloc: Got userId from parameter userEntity (fallback): $userId');
        }
      }
      
      // Join user group FIRST to set pending userId
      if (userId != null && userId.isNotEmpty) {
        notificationBloc!.add(JoinUserGroupEvent(userId: userId));
        print('✅ AuthBloc: JoinUserGroupEvent added for user: $userId');
        
        // Initialize SignalR
        notificationBloc!.add(const InitializeSignalREvent());
        print('✅ AuthBloc: InitializeSignalREvent added');
        
        // Start SignalR connection
        notificationBloc!.add(const StartSignalREvent());
        print('✅ AuthBloc: StartSignalREvent added');
      } else {
        print('❌ AuthBloc: No valid userId found for SignalR initialization');
        print('⏳ AuthBloc: Waiting for user profile to load before SignalR initialization...');
        return;
      }
      
    } catch (e) {
      print('❌ AuthBloc: Failed to initialize SignalR: $e');
    }
  }

  void _stopSignalRConnection() {
    if (notificationBloc == null) return;
    
    try {
      print('🛑 AuthBloc: Stopping SignalR connection...');
      notificationBloc!.add(const StopSignalREvent());
      print('✅ AuthBloc: StopSignalREvent added');
    } catch (e) {
      print('❌ AuthBloc: Failed to stop SignalR: $e');
    }
  }

  // (No longer used) Background loader removed in favor of event-based refresh
}
