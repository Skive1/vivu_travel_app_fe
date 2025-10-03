import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/schedule_repository.dart';

class ShareSchedule implements UseCase<String, ShareScheduleParams> {
  final ScheduleRepository _repository;

  ShareSchedule(this._repository);

  @override
  Future<Either<Failure, String>> call(ShareScheduleParams params) async {
    try {
      final sharedCode = await _repository.shareSchedule(params.scheduleId);
      return Right(sharedCode);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class ShareScheduleParams extends Equatable {
  final String scheduleId;

  const ShareScheduleParams({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}
