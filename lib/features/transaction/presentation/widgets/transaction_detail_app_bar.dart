import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../../../core/widgets/page_manager.dart';

class TransactionDetailAppBar extends StatelessWidget {
  final TransactionEntity transaction;
  final PageManager? pageManager;

  const TransactionDetailAppBar({
    super.key,
    required this.transaction,
    this.pageManager,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusColor(),
            _getStatusColor().withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(
          top: statusBarHeight + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        child: Row(
          children: [
              // Back button
              GestureDetector(
                onTap: () {
                  if (pageManager != null) {
                    pageManager!.showTransactionList();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  padding: context.responsivePadding(all: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: context.responsiveIconSize(
                      verySmall: 18,
                      small: 20,
                      large: 22,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chi tiết giao dịch',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.responsiveFontSize(
                          verySmall: 18,
                          small: 20,
                          large: 22,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mã giao dịch: ${transaction.id.substring(0, 8)}...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: context.responsiveFontSize(
                          verySmall: 12,
                          small: 13,
                          large: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: context.responsivePadding(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  transaction.statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.responsiveFontSize(
                      verySmall: 11,
                      small: 12,
                      large: 13,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (transaction.isSuccess) {
      return AppColors.success;
    } else if (transaction.isPending) {
      return AppColors.warning;
    } else if (transaction.isCancelled) {
      return AppColors.error;
    }
    return AppColors.textHint;
  }
}
