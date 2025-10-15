import 'activity_model.dart';

class ActivitiesResponse {
  final String participantRole;
  final List<ActivityModel> responses;

  const ActivitiesResponse({
    required this.participantRole,
    required this.responses,
  });

  factory ActivitiesResponse.fromJson(Map<String, dynamic> json) {
    return ActivitiesResponse(
      participantRole: json['participantRole'] as String,
      responses: (json['responses'] as List)
          .map((item) => ActivityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantRole': participantRole,
      'responses': responses.map((item) => item.toJson()).toList(),
    };
  }
}
