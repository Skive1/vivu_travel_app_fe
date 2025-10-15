import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kick_participant_result.dart';
import '../repositories/schedule_repository.dart';

class KickParticipant implements UseCase<KickParticipantResult, KickParticipantParams> {
  final ScheduleRepository repository;

  KickParticipant(this.repository);

  @override
  Future<Either<Failure, KickParticipantResult>> call(KickParticipantParams params) {
    return repository.kickParticipant(params.scheduleId, params.participantId);
  }
}

class KickParticipantParams {
  final String scheduleId;
  final String participantId;

  const KickParticipantParams({required this.scheduleId, required this.participantId});
}


