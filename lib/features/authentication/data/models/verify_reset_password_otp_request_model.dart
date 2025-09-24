class VerifyResetPasswordOtpRequestModel {
  final String email;
  final String otpCode;
  const VerifyResetPasswordOtpRequestModel({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otpCode': otpCode,
    };
  }
}