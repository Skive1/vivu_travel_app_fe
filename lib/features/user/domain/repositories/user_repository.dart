import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../authentication/domain/entities/user_entity.dart';


abstract class UserRepository {
    Future<Either<Failure, UserEntity>> updateUserProfile({
    required String dateOfBirth,
    required String address,
    required String name,
    required String phoneNumber,
    required String gender,
    String? avatarFilePath,
  });
}