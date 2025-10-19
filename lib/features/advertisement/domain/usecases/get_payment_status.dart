import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/advertisement_repositories.dart';

class GetPaymentStatus implements UseCase<PaymentStatusEntity, String> {
  final AdvertisementRepository repository;

  GetPaymentStatus(this.repository);

  @override
  Future<Either<Failure, PaymentStatusEntity>> call(String transactionId) async {
    return await repository.getPaymentStatus(transactionId);
  }
}
