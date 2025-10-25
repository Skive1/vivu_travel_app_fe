import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_data_entity.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';
import '../../../schedule/domain/repositories/schedule_repository.dart';
import '../../../schedule/data/models/create_schedule_request.dart';

class CreateScheduleFromAI implements UseCase<ScheduleEntity, ScheduleDataEntity> {
  final ScheduleRepository _repository;

  CreateScheduleFromAI({required ScheduleRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, ScheduleEntity>> call(ScheduleDataEntity params) async {
    try {
      // Convert ScheduleDataEntity to CreateScheduleRequest
      final request = CreateScheduleRequest(
        sharedCode: params.sharedCode,
        title: params.title,
        startLocation: params.startLocation,
        destination: params.destination,
        startDate: DateTime.parse(params.startDate),
        endDate: DateTime.parse(params.endDate),
        participantsCount: params.participantsCount,
        notes: params.notes,
        isShared: params.isShared,
      );

      final schedule = await _repository.createSchedule(request);
      return Right(schedule);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
