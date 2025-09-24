class ResetPasswordResponseModel {
  final String message;
  const ResetPasswordResponseModel({
    required this.message,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      message: json['message'],
    );
  }
}