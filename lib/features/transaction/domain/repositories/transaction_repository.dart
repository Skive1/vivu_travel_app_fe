import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Get all transactions for current user
  Future<List<TransactionEntity>> getAllTransactions();
}
