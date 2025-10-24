import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class TransactionAppBar extends StatelessWidget {
  final VoidCallback onRefresh;

  const TransactionAppBar({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
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
      child: SafeArea(
        child: Padding(
          padding: context.responsivePadding(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
                      'Lịch sử giao dịch',
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
                      'Xem tất cả giao dịch của bạn',
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
              
              // Refresh button
              GestureDetector(
                onTap: onRefresh,
                child: Container(
                  padding: context.responsivePadding(all: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: context.responsiveIconSize(
                      verySmall: 18,
                      small: 20,
                      large: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
