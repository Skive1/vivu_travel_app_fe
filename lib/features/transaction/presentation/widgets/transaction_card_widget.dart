import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionCardWidget extends StatefulWidget {
  final TransactionEntity transaction;
  final VoidCallback onTap;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.transaction.isSuccess) {
      return AppColors.success;
    } else if (widget.transaction.isPending) {
      return AppColors.warning;
    } else if (widget.transaction.isCancelled) {
      return AppColors.error;
    }
    return AppColors.textHint;
  }

  Color _getStatusBackgroundColor() {
    if (widget.transaction.isSuccess) {
      return AppColors.success.withOpacity(0.1);
    } else if (widget.transaction.isPending) {
      return AppColors.warning.withOpacity(0.1);
    } else if (widget.transaction.isCancelled) {
      return AppColors.error.withOpacity(0.1);
    }
    return AppColors.textHint.withOpacity(0.1);
  }

  Color _getTransactionTypeColor() {
    // Dựa trên nội dung giao dịch để xác định loại
    final content = widget.transaction.transactionContent.toLowerCase();
    if (content.contains('payment') || content.contains('pay')) {
      return AppColors.primary;
    } else if (content.contains('transfer')) {
      return AppColors.accent;
    } else if (content.contains('cashback')) {
      return AppColors.success;
    } else if (content.contains('cash-in')) {
      return AppColors.info;
    }
    return AppColors.primary;
  }

  IconData _getTransactionTypeIcon() {
    final content = widget.transaction.transactionContent.toLowerCase();
    if (content.contains('payment') || content.contains('pay')) {
      return Icons.payment;
    } else if (content.contains('transfer')) {
      return Icons.swap_horiz;
    } else if (content.contains('cashback')) {
      return Icons.shopping_cart;
    } else if (content.contains('cash-in')) {
      return Icons.add_card;
    }
    return Icons.receipt_long;
  }

  String _getTransactionTypeText() {
    final content = widget.transaction.transactionContent.toLowerCase();
    if (content.contains('payment') || content.contains('pay')) {
      return 'Payment';
    } else if (content.contains('transfer')) {
      return 'Transfer to card';
    } else if (content.contains('cashback')) {
      return 'Cashback from purchase';
    } else if (content.contains('cash-in')) {
      return 'Cash-in';
    }
    return 'Transaction';
  }

  String _getTransactionDescription() {
    // Tạo mô tả dựa trên gateway hoặc nội dung
    if (widget.transaction.gateway != null) {
      return 'From ${widget.transaction.gateway}';
    } else if (widget.transaction.transactionContent.toLowerCase().contains('amazon')) {
      return 'Purchase from Amazon.com';
    } else if (widget.transaction.transactionContent.toLowerCase().contains('books')) {
      return 'Purchase from Books.com';
    } else if (widget.transaction.transactionContent.toLowerCase().contains('atm')) {
      return 'From ABC Bank ATM';
    } else if (widget.transaction.transactionContent.toLowerCase().contains('funds')) {
      return 'Not enough funds';
    }
    return 'Transaction';
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: context.responsivePadding(
                horizontal: 16,
                vertical: 16,
              ),
              child: Row(
                children: [
                  // Left side - Icon and details
                  Expanded(
                    child: Row(
                      children: [
                        // Transaction type icon
                        Container(
                          width: context.responsiveSpacing(
                            verySmall: 40,
                            small: 44,
                            large: 48,
                          ),
                          height: context.responsiveSpacing(
                            verySmall: 40,
                            small: 44,
                            large: 48,
                          ),
                          decoration: BoxDecoration(
                            color: _getTransactionTypeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTransactionTypeIcon(),
                            color: _getTransactionTypeColor(),
                            size: context.responsiveIconSize(
                              verySmall: 20,
                              small: 22,
                              large: 24,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Transaction details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction type
                              Text(
                                _getTransactionTypeText(),
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 14,
                                    small: 15,
                                    large: 16,
                                  ),
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Description
                              Text(
                                _getTransactionDescription(),
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 12,
                                    small: 13,
                                    large: 14,
                                  ),
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 4),
                              
                              // Transaction ID
                              Text(
                                'Transaction ID ${widget.transaction.id.substring(0, 12)}',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 11,
                                    small: 12,
                                    large: 13,
                                  ),
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Right side - Amount, status, date/time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount
                      Text(
                        widget.transaction.formattedAmount,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 14,
                            small: 15,
                            large: 16,
                          ),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Status badge
                      Container(
                        padding: context.responsivePadding(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusBackgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.transaction.statusText,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 10,
                              small: 11,
                              large: 12,
                            ),
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Date
                      Text(
                        widget.transaction.formattedDate,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 11,
                            small: 12,
                            large: 13,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      
                      // Time
                      Text(
                        widget.transaction.formattedTime,
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 11,
                            small: 12,
                            large: 13,
                          ),
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
