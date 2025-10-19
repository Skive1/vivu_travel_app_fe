import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checkin_entity.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/checkin_request.dart';

class CheckInActivityUseCase implements UseCase<CheckInEntity, CheckInActivityParams> {
  final ScheduleRepository repository;

  CheckInActivityUseCase({required this.repository});

  @override
  Future<Either<Failure, CheckInEntity>> call(CheckInActivityParams params) async {
    return await repository.checkInActivity(params.request);
  }
}

class CheckInActivityParams {
  final CheckInRequest request;

  CheckInActivityParams({required this.request});
}
