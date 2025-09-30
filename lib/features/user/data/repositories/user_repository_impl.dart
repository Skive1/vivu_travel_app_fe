import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../../authentication/domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/update_profile_request_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  Failure _handleException(dynamic error) {
    if (error is DioException) {
      return ErrorMapper.mapDioErrorToFailure(error);
    } else if (error is Exception) {
      return ErrorMapper.mapExceptionToFailure(error);
    } else {
      return ErrorMapper.mapGenericErrorToFailure(error);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String dateOfBirth,
    required String address,
    required String name,
    required String phoneNumber,
    required String gender,
    String? avatarFilePath,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        MultipartFile? avatarFile;
        if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
          final file = File(avatarFilePath);
          if (await file.exists()) {
            avatarFile = await MultipartFile.fromFile(
              file.path,
              filename: p.basename(file.path),
            );
          }
        }

        final request = UpdateProfileRequestModel(
          dateOfBirth: dateOfBirth,
          address: address,
          name: name,
          phoneNumber: phoneNumber,
          gender: gender,
          avatarFile: avatarFile,
        );

        final response = await remoteDataSource.updateProfile(request);

        // NOTE: Previous email/role/flags are preserved upstream (bloc will merge with current state)
        // Here we just construct a partial update applied on top of current entity
        // The caller should supply the previous entity to merge; we will return a minimal UserEntity
        return Right(UserEntity(
          id: response.id,
          email: '',
          name: response.name,
          avatar: response.avatarUrl.isNotEmpty ? response.avatarUrl : null,
          createdAt: null,
          isActive: true,
          roleName: '',
          dateOfBirth: response.dateOfBirth,
          address: response.address,
          phoneNumber: response.phoneNumber,
          gender: response.gender,
        ));
      } catch (e) {
        return Left(_handleException(e));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}


