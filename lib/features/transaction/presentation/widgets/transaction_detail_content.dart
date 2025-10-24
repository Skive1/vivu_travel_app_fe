import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/transaction_entity.dart';
import 'animated_success_checkmark.dart';
import 'animated_pending_indicator.dart';
import 'animated_cancelled_indicator.dart';

class TransactionDetailContent extends StatefulWidget {
  final TransactionEntity transaction;

  const TransactionDetailContent({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailContent> createState() => _TransactionDetailContentState();
}

class _TransactionDetailContentState extends State<TransactionDetailContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: SingleChildScrollView(
          padding: context.responsivePadding(
            horizontal: 16,
            vertical: 20,
            bottom: MediaQuery.of(context).padding.bottom + context.responsive(verySmall: 20, small: 24, large: 28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Summary Card
              _buildSummaryCard(),
              
              SizedBox(
                height: context.responsiveSpacing(
                  verySmall: 20,
                  small: 24,
                  large: 28,
                ),
              ),
              
              // Transaction Details
              _buildDetailsSection(),
              
              SizedBox(
                height: context.responsiveSpacing(
                  verySmall: 20,
                  small: 24,
                  large: 28,
                ),
              ),
              
              // Payment Information
              if (widget.transaction.gateway != null || 
                  widget.transaction.accountNumber != null)
                _buildPaymentSection(),
              
              SizedBox(
                height: context.responsiveSpacing(
                  verySmall: 20,
                  small: 24,
                  large: 28,
                ),
              ),
              
              // Transaction Timeline
              _buildTimelineSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 16,
            small: 18,
            large: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: context.responsivePadding(
          horizontal: 20,
          vertical: 24,
        ),
        child: Column(
          children: [
            // Animated Status Indicator
            _buildStatusIndicator(context),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16,
                small: 20,
                large: 24,
              ),
            ),
            
            // Amount (below indicator)
            Text(
              widget.transaction.formattedAmount,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 28,
                  small: 32,
                  large: 36,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 8,
                small: 10,
                large: 12,
              ),
            ),
            
            // Status
            Container(
              padding: context.responsivePadding(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: _getStatusBackgroundColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.transaction.statusText,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 14,
                        small: 15,
                        large: 16,
                      ),
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16,
                small: 18,
                large: 20,
              ),
            ),
            
            // Transaction content
            Text(
              widget.transaction.transactionContent,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 16,
                  small: 17,
                  large: 18,
                ),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 16,
            small: 18,
            large: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: context.responsivePadding(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin giao dịch',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 18,
                  small: 20,
                  large: 22,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16,
                small: 18,
                large: 20,
              ),
            ),
            
            _buildDetailRow(
              'Mã giao dịch',
              widget.transaction.id,
              Icons.receipt_long,
            ),
            
            _buildDetailRow(
              'Ngày tạo',
              '${widget.transaction.formattedDate} ${widget.transaction.formattedTime}',
              Icons.calendar_today,
            ),
            
            if (widget.transaction.transactionDate != null)
              _buildDetailRow(
                'Ngày giao dịch',
                '${widget.transaction.formattedTransactionDate} ${widget.transaction.formattedTransactionTime}',
                Icons.schedule,
              ),
            
            _buildDetailRow(
              'Nội dung',
              widget.transaction.transactionContent,
              Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 16,
            small: 18,
            large: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: context.responsivePadding(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin thanh toán',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 18,
                  small: 20,
                  large: 22,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16,
                small: 18,
                large: 20,
              ),
            ),
            
            if (widget.transaction.gateway != null)
              _buildDetailRow(
                'Cổng thanh toán',
                widget.transaction.gateway!,
                Icons.account_balance,
              ),
            
            if (widget.transaction.accountNumber != null)
              _buildDetailRow(
                'Số tài khoản',
                '****${widget.transaction.accountNumber!.substring(
                  widget.transaction.accountNumber!.length - 4,
                )}',
                Icons.credit_card,
              ),
            
            if (widget.transaction.referenceNumber != null)
              _buildDetailRow(
                'Mã tham chiếu',
                widget.transaction.referenceNumber!,
                Icons.receipt,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 16,
            small: 18,
            large: 20,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: context.responsivePadding(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lịch sử giao dịch',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 18,
                  small: 20,
                  large: 22,
                ),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16,
                small: 18,
                large: 20,
              ),
            ),
            
            _buildTimelineItem(
              'Giao dịch được tạo',
              '${widget.transaction.formattedDate} ${widget.transaction.formattedTime}',
              Icons.add_circle,
              const Color(0xFF4CAF50),
            ),
            
            if (widget.transaction.transactionDate != null)
              _buildTimelineItem(
                'Giao dịch hoàn thành',
                '${widget.transaction.formattedTransactionDate} ${widget.transaction.formattedTransactionTime}',
                Icons.check_circle,
                _getStatusColor(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          verySmall: 12,
          small: 14,
          large: 16,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: context.responsiveIconSize(
              verySmall: 16,
              small: 18,
              large: 20,
            ),
            color: const Color(0xFF7F8C8D),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 12,
                      small: 13,
                      large: 14,
                    ),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 14,
                      small: 15,
                      large: 16,
                    ),
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveSpacing(
          verySmall: 16,
          small: 18,
          large: 20,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: context.responsivePadding(all: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: context.responsiveIconSize(
                verySmall: 16,
                small: 18,
                large: 20,
              ),
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 14,
                      small: 15,
                      large: 16,
                    ),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 12,
                      small: 13,
                      large: 14,
                    ),
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final size = context.responsive(
      verySmall: 80.0,
      small: 90.0,
      large: 100.0,
    );

    if (widget.transaction.isSuccess) {
      return AnimatedSuccessCheckmark(
        size: size,
        color: AppColors.success,
        animationDuration: const Duration(milliseconds: 1500),
      );
    } else if (widget.transaction.isPending) {
      return AnimatedPendingIndicator(
        size: size,
        color: AppColors.warning,
        animationDuration: const Duration(milliseconds: 1500),
      );
    } else if (widget.transaction.isCancelled) {
      return AnimatedCancelledIndicator(
        size: size,
        color: AppColors.error,
        animationDuration: const Duration(milliseconds: 1200),
      );
    }
    
    // Fallback for unknown status
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textHint.withOpacity(0.1),
        border: Border.all(
          color: AppColors.textHint.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.help_outline,
        color: AppColors.textHint,
        size: size * 0.4,
      ),
    );
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
}
