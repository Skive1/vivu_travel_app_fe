import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/advertisement_repositories.dart';

class GetAllPosts implements UseCase<List<PostEntity>, NoParams> {
  final AdvertisementRepository repository;

  GetAllPosts(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(NoParams params) async {
    return await repository.getAllPosts();
  }
}
