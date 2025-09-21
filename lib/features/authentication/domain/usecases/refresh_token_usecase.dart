import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RefreshTokenUseCase implements UseCase<String, NoParams> {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.refreshToken();
  }
}
