import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/join_schedule_request.dart';
import '../../data/models/join_schedule_response.dart';

class JoinSchedule implements UseCase<JoinScheduleResponse, JoinScheduleParams> {
  final ScheduleRepository repository;

  JoinSchedule(this.repository);

  @override
  Future<Either<Failure, JoinScheduleResponse>> call(JoinScheduleParams params) async {
    return repository.joinSchedule(params.request);
  }
}

class JoinScheduleParams {
  final JoinScheduleRequest request;

  JoinScheduleParams({required this.request});
}
