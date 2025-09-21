class OtpRequestModel {
  final String email;
  final String otpCode;

  const OtpRequestModel({
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