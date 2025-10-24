import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class TransactionEmptyState extends StatefulWidget {
  const TransactionEmptyState({super.key});

  @override
  State<TransactionEmptyState> createState() => _TransactionEmptyStateState();
}

class _TransactionEmptyStateState extends State<TransactionEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Padding(
            padding: context.responsivePadding(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Empty state icon
                Container(
                  padding: context.responsivePadding(all: 24),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: context.responsiveIconSize(
                      verySmall: 48,
                      small: 56,
                      large: 64,
                    ),
                    color: AppColors.primary,
                  ),
                ),
                
                SizedBox(
                  height: context.responsiveSpacing(
                    verySmall: 24,
                    small: 28,
                    large: 32,
                  ),
                ),
                
                // Title
                Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 18,
                      small: 20,
                      large: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(
                  height: context.responsiveSpacing(
                    verySmall: 8,
                    small: 10,
                    large: 12,
                  ),
                ),
                
                // Description
                Text(
                  'Khi bạn thực hiện giao dịch, chúng sẽ xuất hiện ở đây',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 14,
                      small: 15,
                      large: 16,
                    ),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                SizedBox(
                  height: context.responsiveSpacing(
                    verySmall: 32,
                    small: 36,
                    large: 40,
                  ),
                ),
                
                // Action button
                Container(
                  width: double.infinity,
                  height: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // Navigate to explore screen or payment screen
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.explore,
                              color: AppColors.surface,
                              size: context.responsiveIconSize(
                                verySmall: 18,
                                small: 20,
                                large: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Khám phá gói quảng cáo',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 14,
                                  small: 15,
                                  large: 16,
                                ),
                                fontWeight: FontWeight.w600,
                                color: AppColors.surface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
