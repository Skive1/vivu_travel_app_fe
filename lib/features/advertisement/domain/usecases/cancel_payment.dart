import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_entity.dart';
import '../repositories/advertisement_repositories.dart';

class CancelPaymentParams {
  final String transactionId;

  CancelPaymentParams({
    required this.transactionId,
  });
}

class CancelPayment implements UseCase<PaymentStatusEntity, CancelPaymentParams> {
  final AdvertisementRepository repository;

  CancelPayment(this.repository);

  @override
  Future<Either<Failure, PaymentStatusEntity>> call(CancelPaymentParams params) async {
    return await repository.cancelPayment(params.transactionId);
  }
}
