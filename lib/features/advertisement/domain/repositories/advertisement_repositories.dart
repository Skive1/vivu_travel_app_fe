import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/package_entity.dart';
import '../entities/post_entity.dart';
import '../entities/payment_entity.dart';

abstract class AdvertisementRepository {
  Future<Either<Failure, List<PackageEntity>>> getAllPackages();
  Future<Either<Failure, List<PostEntity>>> getAllPosts();
  Future<Either<Failure, PostEntity>> getPostById(String postId);
  Future<Either<Failure, PostEntity>> createPost({
    required String title,
    required String description,
    required String packagePurchaseId,
    required List<String> mediaFiles,
    required List<int> mediaTypes,
  });
  Future<Either<Failure, PaymentEntity>> createPayment({
    required String packageId,
    required int amount,
  });
  Future<Either<Failure, PaymentStatusEntity>> getPaymentStatus(String transactionId);
}
