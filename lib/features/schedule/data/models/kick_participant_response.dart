import 'participant_model.dart';

class KickParticipantResponse {
  final int participantCounts;
  final List<ParticipantModel> scheduleParticipantResponses;

  const KickParticipantResponse({
    required this.participantCounts,
    required this.scheduleParticipantResponses,
  });

  factory KickParticipantResponse.fromJson(Map<String, dynamic> json) {
    print('DEBUG[KickResponse]: Parsing JSON response:');
    print('DEBUG[KickResponse]: Raw JSON: $json');
    
    try {
      final participantCounts = json['participantCounts'] as int?;
      print('DEBUG[KickResponse]: participantCounts = $participantCounts');
      
      final scheduleParticipantResponses = json['scheduleParticipantResponses'] as List?;
      print('DEBUG[KickResponse]: scheduleParticipantResponses = $scheduleParticipantResponses');
      
      if (participantCounts == null) {
        throw Exception('participantCounts is null');
      }
      
      if (scheduleParticipantResponses == null) {
        throw Exception('scheduleParticipantResponses is null');
      }
      
      final participants = scheduleParticipantResponses
          .map((item) {
            print('DEBUG[KickResponse]: Parsing participant: $item');
            return ParticipantModel.fromJson(item as Map<String, dynamic>);
          })
          .toList();
      
      print('DEBUG[KickResponse]: Successfully parsed ${participants.length} participants');
      
      return KickParticipantResponse(
        participantCounts: participantCounts,
        scheduleParticipantResponses: participants,
      );
    } catch (e, stackTrace) {
      print('DEBUG[KickResponse]: Error parsing JSON: $e');
      print('DEBUG[KickResponse]: Stack trace: $stackTrace');
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
