import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateUserProfile(
      dateOfBirth: params.dateOfBirth,
      address: params.address,
      name: params.name,
      phoneNumber: params.phoneNumber,
      gender: params.gender,
      avatarFilePath: params.avatarFilePath,
    );
  }
}

class UpdateProfileParams {
  final String dateOfBirth;
  final String address;
  final String name;
  final String phoneNumber;
  final String gender;
  final String? avatarFilePath;

  UpdateProfileParams({
    required this.dateOfBirth,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    this.avatarFilePath,
  });
}


