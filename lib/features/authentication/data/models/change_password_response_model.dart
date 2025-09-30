import '../../domain/entities/change_password_entity.dart';

class ChangePasswordResponseModel {
  final String message;

  const ChangePasswordResponseModel({
    required this.message,
  });

  factory ChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponseModel(
      message: json['message'] ?? '',
    );
  }

  ChangePasswordEntity toEntity() {
    return ChangePasswordEntity(
      message: message,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangePasswordResponseModel && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'ChangePasswordResponseModel(message: $message)';
}
