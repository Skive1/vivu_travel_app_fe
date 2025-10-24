import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class TransactionLoadingWidget extends StatefulWidget {
  const TransactionLoadingWidget({super.key});

  @override
  State<TransactionLoadingWidget> createState() => _TransactionLoadingWidgetState();
}

class _TransactionLoadingWidgetState extends State<TransactionLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    ));

    _animationController.repeat();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Loading animation
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _animationController.value * 2 * 3.14159,
                    child: Container(
                      width: context.responsiveSpacing(
                        verySmall: 60,
                        small: 70,
                        large: 80,
                      ),
                      height: context.responsiveSpacing(
                        verySmall: 60,
                        small: 70,
                        large: 80,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: AppColors.surface,
                        size: context.responsiveIconSize(
                          verySmall: 28,
                          small: 32,
                          large: 36,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              SizedBox(
                height: context.responsiveSpacing(
                  verySmall: 24,
                  small: 28,
                  large: 32,
                ),
              ),
              
              // Loading text
              Text(
                'Đang tải giao dịch...',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 16,
                    small: 18,
                    large: 20,
                  ),
                  fontWeight: FontWeight.w600,
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
              
              Text(
                'Vui lòng chờ trong giây lát',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 13,
                    small: 14,
                    large: 15,
                  ),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
