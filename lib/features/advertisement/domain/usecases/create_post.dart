import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/advertisement_repositories.dart';

class CreatePostParams {
  final String title;
  final String description;
  final String packagePurchaseId;
  final List<String> mediaFiles;
  final List<int> mediaTypes;

  CreatePostParams({
    required this.title,
    required this.description,
    required this.packagePurchaseId,
    required this.mediaFiles,
    required this.mediaTypes,
  });
}

class CreatePost implements UseCase<PostEntity, CreatePostParams> {
  final AdvertisementRepository repository;

  CreatePost(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    return await repository.createPost(
      title: params.title,
      description: params.description,
      packagePurchaseId: params.packagePurchaseId,
      mediaFiles: params.mediaFiles,
      mediaTypes: params.mediaTypes,
    );
  }
}
