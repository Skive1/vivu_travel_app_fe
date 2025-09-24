class RequestPasswordResetRequestModel {
  final String email;
  const RequestPasswordResetRequestModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}