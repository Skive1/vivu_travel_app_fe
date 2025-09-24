import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendRegisterOtpUseCase implements UseCase<String, ResendRegisterOtpParams> {
  final AuthRepository repository;

  ResendRegisterOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ResendRegisterOtpParams params) async {
    return await repository.resendRegisterOtp(email: params.email);
  }
}

class ResendRegisterOtpParams extends Equatable {
  final String email;

  const ResendRegisterOtpParams({required this.email});

  @override
  List<Object> get props => [email];
}
