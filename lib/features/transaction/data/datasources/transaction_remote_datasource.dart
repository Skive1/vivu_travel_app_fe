import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getAllTransactions();
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient _apiClient;

  TransactionRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final response = await _apiClient.get(
        Endpoints.getAllTransactions,
      );

      if (response.statusCode == 200) {
        // Dio đã tự động parse JSON, response.data đã là List<dynamic>
        final List<dynamic> jsonList = response.data;
        return jsonList
            .map((json) => TransactionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load transactions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }
}
