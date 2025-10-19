import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/package_entity.dart';
import '../repositories/advertisement_repositories.dart';

class GetAllPackages implements UseCase<List<PackageEntity>, NoParams> {
  final AdvertisementRepository repository;

  GetAllPackages(this.repository);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(NoParams params) async {
    return await repository.getAllPackages();
  }
}
