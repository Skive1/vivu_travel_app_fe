import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/package_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/advertisement_repositories.dart';
import '../datasources/advertisement_remote_datasource.dart';

class AdvertisementRepositoryImpl implements AdvertisementRepository {
  final AdvertisementRemoteDataSource remoteDataSource;

  AdvertisementRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<PackageEntity>>> getAllPackages() async {
    try {
      final packages = await remoteDataSource.getAllPackages();
      return Right(packages.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts() async {
    try {
      final posts = await remoteDataSource.getAllPosts();
      return Right(posts.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final post = await remoteDataSource.getPostById(postId);
      return Right(post.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String title,
    required String description,
    required String packagePurchaseId,
    required List<String> mediaFiles,
    required List<int> mediaTypes,
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        title: title,
        description: description,
        packagePurchaseId: packagePurchaseId,
        mediaFiles: mediaFiles,
        mediaTypes: mediaTypes,
      );
      return Right(post.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> createPayment({
    required String packageId,
    required int amount,
  }) async {
    try {
      final payment = await remoteDataSource.createPayment(
        packageId: packageId,
        amount: amount,
      );
      return Right(payment.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(String transactionId) async {
    try {
      final status = await remoteDataSource.getPaymentStatus(transactionId);
      return Right(status.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
