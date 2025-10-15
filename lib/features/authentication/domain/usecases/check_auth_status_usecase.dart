import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/utils/jwt_decoder.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<AuthEntity, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) async {
    try {
      // Step 1: Check if token exists
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        return const Left(AuthFailure('No authentication token found'));
      }

      // Step 2: Get token and validate structure
      final token = await TokenStorage.getToken();
      if (token == null || !JwtDecoder.isValidTokenStructure(token)) {
        await TokenStorage.clearAll();
        return const Left(AuthFailure('Invalid token structure'));
      }

      // Step 3: Check token expiration
      if (JwtDecoder.isExpired(token)) {
        // Token đã hết hạn - clear và return failure
        // DioFactory sẽ handle refresh token automatically
        await TokenStorage.clearAll();
        return const Left(AuthFailure('Session expired. Please login again.'));
      }

      // Step 4: Token is valid and not expired - continue

      // Step 5: Validate claims match backend expectations
      final userClaims = JwtDecoder.getUserClaims(token);
      if (userClaims == null || 
          userClaims['userId'] == null || 
          userClaims['email'] == null) {
        await TokenStorage.clearAll();
        return const Left(AuthFailure('Invalid token claims'));
      }

      // Step 6: Create AuthEntity from validated token
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
      // Clear corrupted data and return failure
      await TokenStorage.clearAll();
      return Left(CacheFailure('Authentication validation failed: ${e.toString()}'));
    }
  }
}
