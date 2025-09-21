import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyRegisterOtpParams {
  final String email;
  final String otpCode;

  const VerifyRegisterOtpParams({
    required this.email,
    required this.otpCode,
  });
}

class VerifyRegisterOtpUseCase implements UseCase<String, VerifyRegisterOtpParams> {
  final AuthRepository repository;

  VerifyRegisterOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyRegisterOtpParams params) async {
    return await repository.verifyRegisterOtp(
      email: params.email,
      otpCode: params.otpCode,
    );
  }
}