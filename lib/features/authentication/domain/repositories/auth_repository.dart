import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';
import '../entities/reset_token_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, void>> logout();
  Future<bool> isLoggedIn();
  Future<Either<Failure, AuthEntity>> checkAuthStatus();
  Future<Either<Failure, String>> refreshToken();
  Future<Either<Failure, UserEntity>> getUserProfile();
  
  // Register methods
  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String dateOfBirth,
    required String name,
    required String address,
    required String phoneNumber,
    required String avatarUrl,
    required String gender,
  });
  
  Future<Either<Failure, String>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, String>> resendRegisterOtp({
    required String email,
  });

  // Forgot Password methods
  Future<Either<Failure, String>> requestPasswordReset({
    required String email,
  });

  Future<Either<Failure, ResetTokenEntity>> verifyResetPasswordOtp({
    required String email,
    required String otpCode,
  });

  Future<Either<Failure, String>> resetPassword({
    required String resetToken,
    required String newPassword,
  });
}
