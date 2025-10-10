import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/create_schedule_request.dart';

class CreateSchedule implements UseCase<ScheduleEntity, CreateScheduleParams> {
  final ScheduleRepository repository;

  CreateSchedule(this.repository);

  @override
  Future<Either<Failure, ScheduleEntity>> call(CreateScheduleParams params) async {
    
    try {
      final schedule = await repository.createSchedule(params.request);
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CreateScheduleParams {
  final CreateScheduleRequest request;

  CreateScheduleParams({required this.request});
}
