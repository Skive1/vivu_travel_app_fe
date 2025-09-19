import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

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
        
        // Save token to secure storage
        await TokenStorage.saveToken(authEntity.token);
        
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
      await TokenStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return await TokenStorage.isTokenValid();
  }

  @override
  Future<Either<Failure, AuthEntity>> checkAuthStatus() async {
    try {
      final token = await TokenStorage.getToken();
      
      if (token == null || token.isEmpty) {
        return const Left(AuthFailure('No token found'));
      }

      if (JwtDecoder.isExpired(token)) {
        // Token expired, clear stored data
        await TokenStorage.clearAll();
        return const Left(AuthFailure('Token expired'));
      }

      // Token is valid, get user info from stored data or JWT
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
      return Left(CacheFailure(e.toString()));
    }
  }
}
