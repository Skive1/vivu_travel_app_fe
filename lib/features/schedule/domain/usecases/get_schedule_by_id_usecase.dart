import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetScheduleById implements UseCase<ScheduleEntity, GetScheduleByIdParams> {
  final ScheduleRepository repository;

  GetScheduleById(this.repository);

  @override
  Future<Either<Failure, ScheduleEntity>> call(GetScheduleByIdParams params) {
    return repository.getScheduleById(params.scheduleId);
  }
}

class GetScheduleByIdParams {
  final String scheduleId;

  const GetScheduleByIdParams({required this.scheduleId});
}
