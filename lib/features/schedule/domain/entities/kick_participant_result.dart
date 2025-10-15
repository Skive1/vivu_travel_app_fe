import 'package:equatable/equatable.dart';
import 'participant_entity.dart';

class KickParticipantResult extends Equatable {
  final int participantCounts;
  final List<ParticipantEntity> scheduleParticipantResponses;

  const KickParticipantResult({
    required this.participantCounts,
    required this.scheduleParticipantResponses,
  });

  @override
  List<Object> get props => [participantCounts, scheduleParticipantResponses];
}
