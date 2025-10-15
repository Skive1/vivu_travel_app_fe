import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart' hide ValidationFailure, TimeoutFailure;
import '../../../../core/errors/error_mapper.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/refresh_token_response_model.dart';
import '../models/register_request_model.dart';
import '../models/register_response_model.dart';
import '../models/otp_request_model.dart';
import '../models/otp_response_model.dart';
import '../models/resend_register_otp_response_model.dart';
import '../models/request_password_reset_request_model.dart';
import '../models/request_password_reset_response_model.dart';
import '../models/verify_reset_password_otp_request_model.dart';
import '../models/verify_reset_password_otp_response_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/reset_password_response_model.dart';
import '../models/get_user_response_model.dart';
import '../models/change_password_request_model.dart';
import '../models/change_password_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<RefreshTokenResponseModel> refreshToken();
  Future<RegisterResponseModel> register(RegisterRequestModel request);
  Future<OtpResponseModel> verifyRegisterOtp(OtpRequestModel request);
  Future<ResendRegisterOtpResponseModel> resendRegisterOtp(String email);
  Future<GetUserResponseModel> getUserProfile();
  
  // Forgot Password methods
  Future<RequestPasswordResetResponseModel> requestPasswordReset(RequestPasswordResetRequestModel request);
  Future<VerifyResetPasswordOtpResponseModel> verifyResetPasswordOtp(VerifyResetPasswordOtpRequestModel request);
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request);
  // Change Password method
  Future<ChangePasswordResponseModel> changePassword(ChangePasswordRequestModel request);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.login,
        data: request.toJson(),
      );
      
      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RefreshTokenResponseModel> refreshToken() async {
    try {
      // Get current refresh token
      final currentRefreshToken = await TokenStorage.getRefreshToken();
      if (currentRefreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Send refresh token as query parameter (temporary until BE supports POST)
      final response = await apiClient.get(
        '${Endpoints.refreshToken}?refreshToken=$currentRefreshToken',
      );
      
      return RefreshTokenResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<GetUserResponseModel> getUserProfile() async {
    try {
      final response = await apiClient.get(Endpoints.me);
      
      return GetUserResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.register,
        data: request.toJson(),
      );
      
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<OtpResponseModel> verifyRegisterOtp(OtpRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.verifyRegisterOtp,
        data: request.toJson(),
      );
      
      return OtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ResendRegisterOtpResponseModel> resendRegisterOtp(String email) async {
    try {
      final response = await apiClient.get(
        '${Endpoints.resendRegisterOtp}?email=$email',
      );
      
      return ResendRegisterOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<RequestPasswordResetResponseModel> requestPasswordReset(RequestPasswordResetRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.requestPasswordReset,
        data: request.toJson(),
      );
      
      return RequestPasswordResetResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<VerifyResetPasswordOtpResponseModel> verifyResetPasswordOtp(VerifyResetPasswordOtpRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.verifyResetPasswordOtp,
        data: request.toJson(),
      );
      
      return VerifyResetPasswordOtpResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ResetPasswordResponseModel> resetPassword(ResetPasswordRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.resetPassword,
        data: request.toJson(),
      );
      
      return ResetPasswordResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ChangePasswordResponseModel> changePassword(ChangePasswordRequestModel request) async {
    try {
      final response = await apiClient.post(
        Endpoints.changePassword,
        data: request.toJson(),
      );
      
      return ChangePasswordResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    // Map DioException to appropriate custom Exception
    final failure = ErrorMapper.mapDioErrorToFailure(error);
    
    // Convert Failure back to Exception for DataSource layer
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
