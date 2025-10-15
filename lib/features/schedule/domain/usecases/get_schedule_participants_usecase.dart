import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';
import '../entities/participant_entity.dart';

class GetScheduleParticipants implements UseCase<List<ParticipantEntity>, GetScheduleParticipantsParams> {
  final ScheduleRepository repository;

  GetScheduleParticipants(this.repository);

  @override
  Future<Either<Failure, List<ParticipantEntity>>> call(GetScheduleParticipantsParams params) async {
    return repository.getScheduleParticipants(params.scheduleId);
  }
}

class GetScheduleParticipantsParams {
  final String scheduleId;

  GetScheduleParticipantsParams({required this.scheduleId});
}
