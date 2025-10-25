import '../../domain/entities/ai_request_entity.dart';

class AIRequestModel extends AIRequestEntity {
  const AIRequestModel({
    required super.message,
  });

  factory AIRequestModel.fromEntity(AIRequestEntity entity) {
    return AIRequestModel(
      message: entity.message,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': message,
    };
  }

  factory AIRequestModel.fromJson(Map<String, dynamic> json) {
    return AIRequestModel(
      message: json['text'] as String,
    );
  }
}
