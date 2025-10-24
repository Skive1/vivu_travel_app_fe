import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class GetAllTransactions {
  final TransactionRepository _repository;

  GetAllTransactions(this._repository);

  Future<List<TransactionEntity>> call() async {
    return await _repository.getAllTransactions();
  }
}
