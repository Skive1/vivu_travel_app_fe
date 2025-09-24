import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reset_token_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyResetPasswordOtpUseCase implements UseCase<ResetTokenEntity, VerifyResetPasswordOtpParams> {
  final AuthRepository repository;

  VerifyResetPasswordOtpUseCase(this.repository);

  @override
  Future<Either<Failure, ResetTokenEntity>> call(VerifyResetPasswordOtpParams params) async {
    return await repository.verifyResetPasswordOtp(
      email: params.email,
      otpCode: params.otpCode,
    );
  }
}

class VerifyResetPasswordOtpParams extends Equatable {
  final String email;
  final String otpCode;

  const VerifyResetPasswordOtpParams({
    required this.email,
    required this.otpCode,
  });

  @override
  List<Object> get props => [email, otpCode];
}
