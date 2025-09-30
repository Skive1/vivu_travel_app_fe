class ChangePasswordRequestModel {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequestModel({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangePasswordRequestModel &&
        other.oldPassword == oldPassword &&
        other.newPassword == newPassword;
  }

  @override
  int get hashCode => oldPassword.hashCode ^ newPassword.hashCode;

  @override
  String toString() => 'ChangePasswordRequestModel(oldPassword: $oldPassword, newPassword: $newPassword)';
}
