import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase implements UseCase<AuthEntity, NoParams> {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  @override
  Future<Either<Failure, AuthEntity>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}
