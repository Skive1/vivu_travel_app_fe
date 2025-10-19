import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/advertisement_repositories.dart';

class GetPostById implements UseCase<PostEntity, String> {
  final AdvertisementRepository repository;

  GetPostById(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(String postId) async {
    return await repository.getPostById(postId);
  }
}
