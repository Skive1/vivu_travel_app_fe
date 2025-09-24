import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestPasswordResetUseCase implements UseCase<String, RequestPasswordResetParams> {
  final AuthRepository repository;

  RequestPasswordResetUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RequestPasswordResetParams params) async {
    return await repository.requestPasswordReset(email: params.email);
  }
}

class RequestPasswordResetParams extends Equatable {
  final String email;

  const RequestPasswordResetParams({required this.email});

  @override
  List<Object> get props => [email];
}
