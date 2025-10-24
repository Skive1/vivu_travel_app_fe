import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_all_transactions.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetAllTransactions _getAllTransactions;

  TransactionBloc({
    required GetAllTransactions getAllTransactions,
  })  : _getAllTransactions = getAllTransactions,
        super(TransactionInitial()) {
    on<GetAllTransactionsEvent>(_onGetAllTransactions);
    on<RefreshTransactionsEvent>(_onRefreshTransactions);
  }

  Future<void> _onGetAllTransactions(
    GetAllTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _getAllTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }

  Future<void> _onRefreshTransactions(
    RefreshTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await _getAllTransactions();
      emit(TransactionLoaded(transactions: transactions));
    } catch (e) {
      emit(TransactionError(message: e.toString()));
    }
  }
}
