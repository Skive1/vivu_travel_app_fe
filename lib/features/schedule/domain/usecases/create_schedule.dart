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
    print('🔧 CreateSchedule UseCase: Starting');
    print('🔧 Request: ${params.request.toJson()}');
    
    try {
      final schedule = await repository.createSchedule(params.request);
      print('✅ CreateSchedule UseCase: Success - ${schedule.id}');
      return Right(schedule);
    } catch (e) {
      print('❌ CreateSchedule UseCase: Error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CreateScheduleParams {
  final CreateScheduleRequest request;

  CreateScheduleParams({required this.request});
}
