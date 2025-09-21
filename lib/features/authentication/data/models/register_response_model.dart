class RegisterResponseModel {
  final String message;

  const RegisterResponseModel({
    required this.message,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: json['message'] ?? '',
    );
  }
}