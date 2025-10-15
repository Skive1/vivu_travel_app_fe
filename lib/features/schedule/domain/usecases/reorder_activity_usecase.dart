import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';

class ReorderActivity {
  final ScheduleRepository _repository;

  ReorderActivity(this._repository);

  Future<Either<Failure, Unit>> call({required int newIndex, required int activityId}) async {
    return _repository.reorderActivity(newIndex: newIndex, activityId: activityId);
  }
}


