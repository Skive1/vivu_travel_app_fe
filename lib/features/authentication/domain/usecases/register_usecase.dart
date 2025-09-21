import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String dateOfBirth;
  final String name;
  final String address;
  final String phoneNumber;
  final String avatarUrl;
  final String gender;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.gender,
  });
}

class RegisterUseCase implements UseCase<String, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      dateOfBirth: params.dateOfBirth,
      name: params.name,
      address: params.address,
      phoneNumber: params.phoneNumber,
      avatarUrl: params.avatarUrl,
      gender: params.gender,
    );
  }
}
