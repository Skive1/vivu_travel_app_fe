import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
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
      // Call backend logout endpoint if needed
      if (await networkInfo.isConnected) {
        try {
          // await remoteDataSource.logout(); // Uncomment khi có API
        } catch (e) {
          // Continue with local logout even if server call fails
        }
      }
      
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
    // Delegate to UseCase logic via repository pattern
    return await CheckAuthStatusUseCase(this).call(NoParams());
  }
}
