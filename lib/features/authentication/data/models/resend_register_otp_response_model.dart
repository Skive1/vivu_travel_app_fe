class ResendRegisterOtpResponseModel {
  final String message;

  const ResendRegisterOtpResponseModel({
    required this.message,
  });

  factory ResendRegisterOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return ResendRegisterOtpResponseModel(
      message: json['message'],
    );
  }
}
