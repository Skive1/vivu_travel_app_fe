import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class GetAllTransactionsEvent extends TransactionEvent {
  const GetAllTransactionsEvent();
}

class RefreshTransactionsEvent extends TransactionEvent {
  const RefreshTransactionsEvent();
}
