import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';

class ChangeParticipantRole implements UseCase<Unit, ChangeParticipantRoleParams> {
  final ScheduleRepository repository;

  ChangeParticipantRole(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ChangeParticipantRoleParams params) {
    return repository.changeParticipantRole(params.scheduleId, params.participantId);
  }
}

class ChangeParticipantRoleParams {
  final String scheduleId;
  final String participantId;

  const ChangeParticipantRoleParams({required this.scheduleId, required this.participantId});
}


