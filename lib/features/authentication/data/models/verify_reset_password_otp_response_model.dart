import '../../domain/entities/reset_token_entity.dart';

class VerifyResetPasswordOtpResponseModel {
  final String resetToken;
  const VerifyResetPasswordOtpResponseModel({
    required this.resetToken,
  });

  factory VerifyResetPasswordOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyResetPasswordOtpResponseModel(
      resetToken: json['resetToken'],
    );
  }

  ResetTokenEntity toEntity(String email) {
    return ResetTokenEntity(
      resetToken: resetToken,
      email: email,
    );
  }
}