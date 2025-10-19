import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';

class RestoreScheduleUseCase implements UseCase<String, RestoreScheduleParams> {
  final ScheduleRepository repository;

  RestoreScheduleUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(RestoreScheduleParams params) async {
    return await repository.restoreSchedule(params.scheduleId);
  }
}

class RestoreScheduleParams {
  final String scheduleId;

  RestoreScheduleParams({required this.scheduleId});
}
