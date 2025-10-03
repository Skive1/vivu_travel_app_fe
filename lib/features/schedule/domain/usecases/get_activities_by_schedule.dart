import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/activity_entity.dart';
import '../repositories/schedule_repository.dart';

class GetActivitiesBySchedule implements UseCase<List<ActivityEntity>, GetActivitiesByScheduleParams> {
  final ScheduleRepository _repository;

  GetActivitiesBySchedule(this._repository);

  @override
  Future<Either<Failure, List<ActivityEntity>>> call(GetActivitiesByScheduleParams params) async {
    try {
      final activities = await _repository.getActivitiesBySchedule(params.scheduleId);
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetActivitiesByScheduleParams extends Equatable {
  final String scheduleId;

  const GetActivitiesByScheduleParams({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}
