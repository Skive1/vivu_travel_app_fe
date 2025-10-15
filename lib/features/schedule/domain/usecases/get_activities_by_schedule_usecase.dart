import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/activity_entity.dart';
import '../repositories/schedule_repository.dart';

class GetActivitiesBySchedule
    implements UseCase<List<ActivityEntity>, GetActivitiesByScheduleParams> {
  final ScheduleRepository _repository;

  GetActivitiesBySchedule(this._repository);

  @override
  Future<Either<Failure, List<ActivityEntity>>> call(
    GetActivitiesByScheduleParams params,
  ) async {
    try {
      final activities = await _repository.getActivitiesBySchedule(
        params.scheduleId,
        params.date,
      );
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetActivitiesByScheduleParams extends Equatable {
  final String scheduleId;
  final DateTime date;

  const GetActivitiesByScheduleParams({
    required this.scheduleId,
    required this.date,
  });

  @override
  List<Object> get props => [scheduleId, date];
}
