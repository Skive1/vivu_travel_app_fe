import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/update_schedule_request.dart';

class UpdateSchedule implements UseCase<ScheduleEntity, UpdateScheduleParams> {
  final ScheduleRepository repository;

  UpdateSchedule(this.repository);

  @override
  Future<Either<Failure, ScheduleEntity>> call(UpdateScheduleParams params) async {  
    try {
      final schedule = await repository.updateSchedule(params.scheduleId, params.request);
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class UpdateScheduleParams {
  final String scheduleId;
  final UpdateScheduleRequest request;

  UpdateScheduleParams({
    required this.scheduleId,
    required this.request,
  });
}
