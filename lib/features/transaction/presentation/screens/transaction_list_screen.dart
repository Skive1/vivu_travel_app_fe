import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_list_widget.dart';
import '../widgets/transaction_header_widget.dart';
import '../widgets/transaction_empty_state.dart';
import '../widgets/transaction_loading_widget.dart';
import '../widgets/transaction_error_widget.dart';
import '../../../../core/widgets/page_manager.dart';

class TransactionListScreen extends StatefulWidget {
  final PageManager? pageManager;
  
  const TransactionListScreen({
    super.key,
    this.pageManager,
  });

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Load transactions when screen initializes
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

  Widget _buildStateWidget(TransactionState state) {
    if (state is TransactionLoading) {
      return const TransactionLoadingWidget(key: ValueKey('loading'));
    } else if (state is TransactionLoaded) {
      if (state.transactions.isEmpty) {
        return const TransactionEmptyState(key: ValueKey('empty'));
      }
      return TransactionListWidget(
        key: const ValueKey('loaded'),
        transactions: state.transactions,
        onRefresh: _onRefresh,
        pageManager: widget.pageManager,
      );
    } else if (state is TransactionError) {
      return TransactionErrorWidget(
        key: const ValueKey('error'),
        message: state.message,
        onRetry: () {
          context.read<TransactionBloc>().add(
            const GetAllTransactionsEvent(),
          );
        },
      );
    }
    return const TransactionLoadingWidget(key: ValueKey('default'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBody: true,
      body: SafeArea(
        child: Column(
          children: [
            // Header với back button và search/filter
            TransactionHeaderWidget(
              onRefresh: _onRefresh,
              pageManager: widget.pageManager,
            ),
            
            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _fadeAnimation,
                    curve: Curves.easeOutCubic,
                  )),
                  child: BlocConsumer<TransactionBloc, TransactionState>(
                    listener: (context, state) {
                      if (state is TransactionError) {
                        DialogUtils.showErrorDialog(
                          context: context,
                          message: state.message,
                          title: 'Lỗi tải giao dịch',
                        );
                      }
                    },
                    builder: (context, state) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: _buildStateWidget(state),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
