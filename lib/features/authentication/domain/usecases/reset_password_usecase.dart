import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<String, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResetPasswordParams params) async {
    return await repository.resetPassword(
      resetToken: params.resetToken,
      newPassword: params.newPassword,
    );
  }
}

class ResetPasswordParams extends Equatable {
  final String resetToken;
  final String newPassword;

  const ResetPasswordParams({
    required this.resetToken,
    required this.newPassword,
  });

  @override
  List<Object> get props => [resetToken, newPassword];
}