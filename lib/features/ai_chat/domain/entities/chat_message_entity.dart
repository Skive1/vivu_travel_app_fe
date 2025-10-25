import 'ai_response_entity.dart';

class ChatMessageEntity {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final AIResponseEntity? aiResponse;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.aiResponse,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageEntity &&
        other.id == id &&
        other.content == content &&
        other.isUser == isUser &&
        other.timestamp == timestamp &&
        other.aiResponse == aiResponse;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      content,
      isUser,
      timestamp,
      aiResponse,
    );
  }
}
