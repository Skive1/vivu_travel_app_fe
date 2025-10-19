import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/media_entity.dart';
import '../repositories/schedule_repository.dart';

class GetMediaByActivityUseCase implements UseCase<List<MediaEntity>, GetMediaByActivityParams> {
  final ScheduleRepository repository;

  GetMediaByActivityUseCase({required this.repository});

  @override
  Future<Either<Failure, List<MediaEntity>>> call(GetMediaByActivityParams params) async {
    return await repository.getMediaByActivity(params.activityId);
  }
}

class GetMediaByActivityParams {
  final int activityId;

  GetMediaByActivityParams({required this.activityId});
}
