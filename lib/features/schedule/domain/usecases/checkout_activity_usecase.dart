import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checkin_entity.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/checkout_request.dart';

class CheckOutActivityUseCase implements UseCase<CheckInEntity, CheckOutActivityParams> {
  final ScheduleRepository repository;

  CheckOutActivityUseCase({required this.repository});

  @override
  Future<Either<Failure, CheckInEntity>> call(CheckOutActivityParams params) async {
    return await repository.checkOutActivity(params.request);
  }
}

class CheckOutActivityParams {
  final CheckOutRequest request;

  CheckOutActivityParams({required this.request});
}
