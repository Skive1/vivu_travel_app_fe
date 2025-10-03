import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entity.dart';
import '../repositories/schedule_repository.dart';

class GetSchedulesByParticipant implements UseCase<List<ScheduleEntity>, GetSchedulesByParticipantParams> {
  final ScheduleRepository _repository;

  GetSchedulesByParticipant(this._repository);

  @override
  Future<Either<Failure, List<ScheduleEntity>>> call(GetSchedulesByParticipantParams params) async {
    try {
      final schedules = await _repository.getSchedulesByParticipant(params.participantId);
      return Right(schedules);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetSchedulesByParticipantParams extends Equatable {
  final String participantId;

  const GetSchedulesByParticipantParams({required this.participantId});

  @override
  List<Object> get props => [participantId];
}
