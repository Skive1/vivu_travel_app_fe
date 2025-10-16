import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kick_participant_result.dart';
import '../repositories/schedule_repository.dart';

class LeaveSchedule implements UseCase<KickParticipantResult, LeaveScheduleParams> {
  final ScheduleRepository repository;

  LeaveSchedule(this.repository);

  @override
  Future<Either<Failure, KickParticipantResult>> call(LeaveScheduleParams params) {
    return repository.leaveSchedule(params.scheduleId, params.userId);
  }
}

class LeaveScheduleParams {
  final String scheduleId;
  final String userId;

  const LeaveScheduleParams({required this.scheduleId, required this.userId});
}


