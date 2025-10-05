import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/create_activity_request.dart';
import '../entities/activity_entity.dart';
import '../repositories/schedule_repository.dart';

class CreateActivity {
  final ScheduleRepository _repository;

  CreateActivity(this._repository);

  Future<Either<Failure, ActivityEntity>> call(CreateActivityParams params) async {
    try {
      final activity = await _repository.addActivity(params.request);
      return Right(activity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CreateActivityParams {
  final CreateActivityRequest request;

  CreateActivityParams({required this.request});
}


