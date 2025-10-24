import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl({
    required TransactionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      final transactionModels = await _remoteDataSource.getAllTransactions();
      return transactionModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions: $e');
    }
  }
}
