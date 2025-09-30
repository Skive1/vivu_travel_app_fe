class ChangePasswordEntity {
  final String message;

  const ChangePasswordEntity({
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangePasswordEntity && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'ChangePasswordEntity(message: $message)';
}
