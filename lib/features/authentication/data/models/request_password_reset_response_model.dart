class RequestPasswordResetResponseModel {
  final String message;
  const RequestPasswordResetResponseModel({
    required this.message,
  });

  factory RequestPasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return RequestPasswordResetResponseModel(
      message: json['message'],
    );
  }
}