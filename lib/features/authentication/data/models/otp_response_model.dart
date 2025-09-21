class OtpResponseModel {
  final String message;

  const OtpResponseModel({
    required this.message,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      message: json['message'] ?? '',
    );
  }
}