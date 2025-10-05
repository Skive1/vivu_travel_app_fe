import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';

class DeleteActivity {
  final ScheduleRepository _repository;

  DeleteActivity(this._repository);

  Future<Either<Failure, Unit>> call(int activityId) async {
    try {
      await _repository.deleteActivity(activityId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}


