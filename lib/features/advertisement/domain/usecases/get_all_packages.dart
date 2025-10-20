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

class GetPurchasedPackagesByPartner implements UseCase<List<PackageEntity>, String> {
  final AdvertisementRepository repository;

  GetPurchasedPackagesByPartner(this.repository);

  @override
  Future<Either<Failure, List<PackageEntity>>> call(String partnerId) async {
    return await repository.getPurchasedPackagesByPartner(partnerId);
  }
}