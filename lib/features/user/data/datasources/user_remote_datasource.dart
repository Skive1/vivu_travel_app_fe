import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart' hide ValidationFailure, TimeoutFailure;
import '../../../../core/errors/error_mapper.dart';
import '../models/update_profile_request_model.dart';
import '../models/update_profile_response_model.dart';

abstract class UserRemoteDataSource {
  Future<UpdateProfileResponseModel> updateProfile(UpdateProfileRequestModel request);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiClient apiClient;

  UserRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UpdateProfileResponseModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await apiClient.put(
        Endpoints.updateProfile,
        data: request.toFormData(),
      );
      return UpdateProfileResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    final failure = ErrorMapper.mapDioErrorToFailure(error);
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        return ServerException(serverFailure.message);
      case NetworkFailure:
        final networkFailure = failure as NetworkFailure;
        return NetworkException(networkFailure.message);
      case AuthFailure:
        final authFailure = failure as AuthFailure;
        return AuthException(authFailure.message);
      case ValidationFailure:
        final validationFailure = failure as ValidationFailure;
        return ValidationException(validationFailure.message);
      case TimeoutFailure:
        final timeoutFailure = failure as TimeoutFailure;
        return TimeoutException(timeoutFailure.message);
      default:
        return ServerException(failure.message);
    }
  }
}
