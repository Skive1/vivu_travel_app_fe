import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class TransactionErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const TransactionErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<TransactionErrorWidget> createState() => _TransactionErrorWidgetState();
}

class _TransactionErrorWidgetState extends State<TransactionErrorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
                // Error icon
                Container(
                  padding: context.responsivePadding(all: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: context.responsiveIconSize(
                      verySmall: 48,
                      small: 56,
                      large: 64,
                    ),
                    color: AppColors.error,
                  ),
                ),
                
                SizedBox(
                  height: context.responsiveSpacing(
                    verySmall: 24,
                    small: 28,
                    large: 32,
                  ),
                ),
                
                // Error title
                Text(
                  'Không thể tải giao dịch',
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
                
                // Error message
                Text(
                  widget.message,
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
                
                // Retry button
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
                      onTap: widget.onRetry,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.refresh,
                              color: AppColors.surface,
                              size: context.responsiveIconSize(
                                verySmall: 18,
                                small: 20,
                                large: 22,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Thử lại',
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
