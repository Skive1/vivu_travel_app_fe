import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/reset_token_entity.dart';
import '../../domain/entities/change_password_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/otp_request_model.dart';
import '../models/request_password_reset_request_model.dart';
import '../models/verify_reset_password_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/change_password_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
  });

  /// Helper method to handle exceptions consistently
  Failure _handleException(dynamic error) {
    if (error is DioException) {
      return ErrorMapper.mapDioErrorToFailure(error);
    } else if (error is Exception) {
      return ErrorMapper.mapExceptionToFailure(error);
    } else {
      return ErrorMapper.mapGenericErrorToFailure(error);
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(email: email, password: password);
      final response = await remoteDataSource.login(request);
      final authEntity = response.toEntity();

      // Save both tokens in a single optimized batch operation
      final saveSuccess = await TokenStorage.saveBothTokens(
        authEntity.token,
        response.refreshToken,
      );

      if (!saveSuccess) {
        return const Left(CacheFailure('Failed to save authentication tokens'));
      }

      return Right(authEntity);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final response = await remoteDataSource.getUserProfile();
      return Right(response.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Local logout only - clear all tokens from secure storage
      await TokenStorage.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isTokenValid();
  }

  @override
  Future<Either<Failure, AuthEntity>> checkAuthStatus() async {
    try {
      // Step 1: Check if token exists
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        return const Left(AuthFailure('No authentication token found'));
      }

      // Step 2: Get token and validate structure
      final token = await TokenStorage.getToken();
      if (token == null || !JwtDecoder.isValidTokenStructure(token)) {
        await TokenStorage.clearAuthData();
        return const Left(AuthFailure('Invalid token structure'));
      }

      // Step 3: Check token expiration
      if (JwtDecoder.isExpired(token)) {
        // Try to refresh token before giving up
        final refreshResult = await refreshToken();
        return refreshResult.fold(
          (failure) {
            // Refresh failed - clear all tokens and return failure
            return Left(AuthFailure('Session expired. Please login again.'));
          },
          (newToken) {
            // Refresh successful - get new token and create AuthEntity
            return _createAuthEntityFromToken(newToken);
          },
        );
      }

      // Step 4: Create AuthEntity from validated token
      return _createAuthEntityFromToken(token);
      
    } catch (e) {
      // Clear corrupted data and return failure
      await TokenStorage.clearAuthData();
      return Left(CacheFailure('Authentication validation failed: ${e.toString()}'));
    }
  }

  /// Helper method to create AuthEntity from token
  Future<Either<Failure, AuthEntity>> _createAuthEntityFromToken(String token) async {
    try {
      // Validate claims match backend expectations
      final userClaims = JwtDecoder.getUserClaims(token);
      if (userClaims == null || 
          userClaims['userId'] == null || 
          userClaims['email'] == null) {
        await TokenStorage.clearAuthData();
        return const Left(AuthFailure('Invalid token claims'));
      }

      // Create AuthEntity from validated token
      final userName = await TokenStorage.getUserName() ?? 
                      JwtDecoder.getUserName(token) ?? 
                      'Unknown User';
      
      final expiryDate = JwtDecoder.getExpiryDate(token) ?? 
                        DateTime.now().add(const Duration(hours: 1));

      final authEntity = AuthEntity(
        token: token,
        userName: userName,
        expiresAt: expiryDate,
      );

      return Right(authEntity);
    } catch (e) {
      await TokenStorage.clearAuthData();
      return Left(CacheFailure('Failed to create auth entity: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final response = await remoteDataSource.refreshToken();

      // Save new tokens using batch operation for consistency
      final saveSuccess = await TokenStorage.saveBothTokens(
        response.accessToken,
        response.refreshToken,
      );
      if (!saveSuccess) {
        return const Left(CacheFailure('Failed to save new tokens'));
      }

      return Right(response.accessToken);
    } catch (e) {
      // If refresh fails, clear all tokens
      await TokenStorage.clearAuthData();
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> register({
    required String email,
    required String password,
    required String dateOfBirth,
    required String name,
    required String address,
    required String phoneNumber,
    required String gender,
  }) async {
    try {
      final request = RegisterRequestModel(
        email: email,
        password: password,
        dateOfBirth: dateOfBirth,
        name: name,
        address: address,
        phoneNumber: phoneNumber,
        gender: gender,
      );

      final response = await remoteDataSource.register(request);
      return Right(response.message);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final request = OtpRequestModel(email: email, otpCode: otpCode);
      final response = await remoteDataSource.verifyRegisterOtp(request);
      return Right(response.message);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final request = RequestPasswordResetRequestModel(email: email);
      final response = await remoteDataSource.requestPasswordReset(request);
      return Right(response.message);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, ResetTokenEntity>> verifyResetPasswordOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final request = VerifyResetPasswordOtpRequestModel(
        email: email,
        otpCode: otpCode,
      );
      final response = await remoteDataSource.verifyResetPasswordOtp(request);
      return Right(response.toEntity(email));
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final request = ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      final response = await remoteDataSource.resetPassword(request);
      return Right(response.message);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> resendRegisterOtp({
    required String email,
  }) async {
    try {
      final response = await remoteDataSource.resendRegisterOtp(email);
      return Right(response.message);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, ChangePasswordEntity>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final request = ChangePasswordRequestModel(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      final response = await remoteDataSource.changePassword(request);
      return Right(response.toEntity());
    } catch (e) {
      return Left(_handleException(e));
    }
  }
}
