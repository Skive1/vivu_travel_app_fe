class AIRequestEntity {
  final String message;

  const AIRequestEntity({
    required this.message,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIRequestEntity && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
