import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class CancelScheduleUseCase implements UseCase<ScheduleEntity, CancelScheduleParams> {
  final ScheduleRepository repository;

  CancelScheduleUseCase({required this.repository});

  @override
  Future<Either<Failure, ScheduleEntity>> call(CancelScheduleParams params) async {
    return await repository.cancelSchedule(params.scheduleId);
  }
}

class CancelScheduleParams {
  final String scheduleId;

  CancelScheduleParams({required this.scheduleId});
}
