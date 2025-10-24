import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import 'transaction_header_widget.dart';
import 'transaction_list_widget.dart';
import 'transaction_empty_state.dart';
import 'transaction_loading_widget.dart';
import 'transaction_error_widget.dart';

class TransactionContentWidget extends StatefulWidget {
  const TransactionContentWidget({super.key});

  @override
  State<TransactionContentWidget> createState() => _TransactionContentWidgetState();
}

class _TransactionContentWidgetState extends State<TransactionContentWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load transactions when widget initializes
    context.read<TransactionBloc>().add(const GetAllTransactionsEvent());
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<TransactionBloc>().add(const RefreshTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF6F8FA),
      child: Column(
        children: [
          // Header với card selector và search/filter
          TransactionHeaderWidget(
            onRefresh: _onRefresh,
          ),
          
          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const TransactionLoadingWidget();
                  } else if (state is TransactionLoaded) {
                    if (state.transactions.isEmpty) {
                      return const TransactionEmptyState();
                    }
                    return TransactionListWidget(
                      transactions: state.transactions,
                      onRefresh: _onRefresh,
                    );
                  } else if (state is TransactionError) {
                    return TransactionErrorWidget(
                      message: state.message,
                      onRetry: () {
                        context.read<TransactionBloc>().add(
                          const GetAllTransactionsEvent(),
                        );
                      },
                    );
                  }
                  return const TransactionLoadingWidget();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
