import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/advertisement_repositories.dart';

class CreatePaymentParams {
  final String packageId;
  final int amount;

  CreatePaymentParams({
    required this.packageId,
    required this.amount,
  });
}

class CreatePayment implements UseCase<PaymentEntity, CreatePaymentParams> {
  final AdvertisementRepository repository;

  CreatePayment(this.repository);

  @override
  Future<Either<Failure, PaymentEntity>> call(CreatePaymentParams params) async {
    return await repository.createPayment(
      packageId: params.packageId,
      amount: params.amount,
    );
  }
}
