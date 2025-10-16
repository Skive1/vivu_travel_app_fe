import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
    final t0 = DateTime.now();
    debugPrint('[TIMING][Usecase] GetActivities start');
    try {
      final activities = await _repository.getActivitiesBySchedule(
        params.scheduleId,
        params.date,
      );
      final t1 = DateTime.now();
      debugPrint('[TIMING][Usecase] GetActivities repo finished in ${t1.difference(t0).inMilliseconds}ms');
      return Right(activities);
    } catch (e) {
      final t1 = DateTime.now();
      debugPrint('[TIMING][Usecase] GetActivities error after ${t1.difference(t0).inMilliseconds}ms: $e');
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
