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
        // Try to refresh token before giving up
        final refreshResult = await repository.refreshToken();
        return refreshResult.fold(
          (failure) {
            // Refresh failed - clear all tokens and return failure
            return Left(AuthFailure('Session expired. Please login again.'));
          },
          (newToken) {
            // Refresh successful - recursively call this method with new token
            return call(params);
          },
        );
      }

      // Step 4: Check if token is near expiry (optional warning)
      final isNearExpiry = await TokenStorage.isTokenNearExpiry();
      if (isNearExpiry) {
        // Token will expire soon - could trigger proactive refresh here
        // For now, just continue with current token
      }

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
