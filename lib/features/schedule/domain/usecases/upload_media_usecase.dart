import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/media_entity.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/upload_media_request.dart';

class UploadMediaUseCase implements UseCase<MediaEntity, UploadMediaParams> {
  final ScheduleRepository repository;

  UploadMediaUseCase({required this.repository});

  @override
  Future<Either<Failure, MediaEntity>> call(UploadMediaParams params) async {
    return await repository.uploadMedia(params.request);
  }
}

class UploadMediaParams {
  final UploadMediaRequest request;

  UploadMediaParams({required this.request});
}
