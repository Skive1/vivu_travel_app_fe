class ResetPasswordRequestModel {
  final String resetToken;
  final String newPassword;
  const ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'resetToken': resetToken,
      'newPassword': newPassword,
    };
  }
}