import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/update_activity_request.dart';
import '../entities/activity_entity.dart';
import '../repositories/schedule_repository.dart';

class UpdateActivity {
  final ScheduleRepository _repository;

  UpdateActivity(this._repository);

  Future<Either<Failure, ActivityEntity>> call(UpdateActivityParams params) async {
    try {
      final activity = await _repository.updateActivity(params.activityId, params.request);
      return Right(activity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class UpdateActivityParams {
  final int activityId;
  final UpdateActivityRequest request;

  UpdateActivityParams({required this.activityId, required this.request});
}


