import 'participant_model.dart';

class KickParticipantResponse {
  final int participantCounts;
  final List<ParticipantModel> scheduleParticipantResponses;

  const KickParticipantResponse({
    required this.participantCounts,
    required this.scheduleParticipantResponses,
  });

  factory KickParticipantResponse.fromJson(Map<String, dynamic> json) {
    try {
      final participantCounts = json['participantCounts'] as int?;
      final scheduleParticipantResponses = json['scheduleParticipantResponses'] as List?;
      if (participantCounts == null) {
        throw Exception('participantCounts is null');
      }
      
      if (scheduleParticipantResponses == null) {
        throw Exception('scheduleParticipantResponses is null');
      }
      
      final participants = scheduleParticipantResponses
          .map((item) {
            return ParticipantModel.fromJson(item as Map<String, dynamic>);
          })
          .toList();
      
      return KickParticipantResponse(
        participantCounts: participantCounts,
        scheduleParticipantResponses: participants,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'participantCounts': participantCounts,
      'scheduleParticipantResponses': scheduleParticipantResponses.map((item) => item.toJson()).toList(),
    };
  }
}
