import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_card_widget.dart';
import '../screens/transaction_detail_screen.dart';
import '../../../../core/widgets/page_manager.dart';

class TransactionListWidget extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final VoidCallback onRefresh;
  final PageManager? pageManager;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    required this.onRefresh,
    this.pageManager,
  });

  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  List<TransactionEntity> _filteredTransactions = [];
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _filteredTransactions = widget.transactions;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.builder(
        padding: context.responsivePadding(
          horizontal: 20,
          bottom: 20,
        ),
        cacheExtent: 1000, // Cache 1000 pixels worth of widgets
        itemCount: _filteredTransactions.length,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: context.responsiveSpacing(
                verySmall: 12,
                small: 14,
                large: 16,
              ),
            ),
            child: FadeTransition(
              opacity: _animationController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    (index * 0.05).clamp(0.0, 0.8),
                    1.0,
                    curve: Curves.easeOutCubic,
                  ),
                )),
                child: RepaintBoundary(
                  child: TransactionCardWidget(
                    transaction: transaction,
                    onTap: () {
                      _navigateToDetail(transaction);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(TransactionEntity transaction) {
    if (widget.pageManager != null) {
      widget.pageManager!.showTransactionDetail(transaction);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => TransactionDetailScreen(
            transaction: transaction,
          ),
        ),
      );
    }
  }
}
