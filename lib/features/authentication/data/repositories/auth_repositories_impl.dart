import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/otp_request_model.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = LoginRequestModel(email: email, password: password);
        final response = await remoteDataSource.login(request);
        final authEntity = response.toEntity();
        
        // Save token with validation
        final saveSuccess = await TokenStorage.saveToken(authEntity.token);
        if (!saveSuccess) {
          return const Left(CacheFailure('Failed to save authentication token'));
        }
        
        // Save refresh token
        await TokenStorage.saveRefreshToken(response.refreshToken);
        
        return Right(authEntity);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Local logout only - clear all tokens from secure storage
      await TokenStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear authentication data: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isTokenValid();
  }

  @override
  Future<Either<Failure, AuthEntity>> checkAuthStatus() async {
    // Delegate to UseCase logic via repository pattern
    return await CheckAuthStatusUseCase(this).call(NoParams());
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.refreshToken();
        
        // Save new tokens
        final saveSuccess = await TokenStorage.saveToken(response.accessToken);
        if (!saveSuccess) {
          return const Left(CacheFailure('Failed to save new access token'));
        }
        
        await TokenStorage.saveRefreshToken(response.refreshToken);
        
        return Right(response.accessToken);
      } catch (e) {
        // If refresh fails, clear all tokens
        await TokenStorage.clearAll();
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
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
    required String avatarUrl,
    required String gender,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = RegisterRequestModel(
          email: email,
          password: password,
          dateOfBirth: dateOfBirth,
          name: name,
          address: address,
          phoneNumber: phoneNumber,
          avatarUrl: avatarUrl,
          gender: gender,
        );
        
        final response = await remoteDataSource.register(request);
        return Right(response.message);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyRegisterOtp({
    required String email,
    required String otpCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final request = OtpRequestModel(email: email, otpCode: otpCode);
        final response = await remoteDataSource.verifyRegisterOtp(request);
        return Right(response.message);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
