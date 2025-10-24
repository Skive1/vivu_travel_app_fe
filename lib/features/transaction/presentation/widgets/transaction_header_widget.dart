import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/widgets/page_manager.dart';

class TransactionHeaderWidget extends StatelessWidget {
  final VoidCallback onRefresh;
  final PageManager? pageManager;

  const TransactionHeaderWidget({
    super.key,
    required this.onRefresh,
    this.pageManager,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.responsivePadding(
        horizontal: 20,
        vertical: 16,
      ),
      child: Column(
        children: [
          // Status bar space
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 8,
              small: 10,
              large: 12,
            ),
          ),
          
          // Header row với back button và action buttons
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () {
                  if (pageManager != null) {
                    pageManager!.showProfileMain();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
                  height: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
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
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: context.responsiveIconSize(
                      verySmall: 18,
                      small: 20,
                      large: 22,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Title
              Expanded(
                child: Text(
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
              ),
              
              // Search button
              GestureDetector(
                onTap: () => _showSearch(context),
                child: Container(
                  width: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
                  height: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
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
                  child: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: context.responsiveIconSize(
                      verySmall: 20,
                      small: 22,
                      large: 24,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Filter button
              GestureDetector(
                onTap: () => _showFilter(context),
                child: Container(
                  width: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
                  height: context.responsiveSpacing(
                    verySmall: 44,
                    small: 48,
                    large: 52,
                  ),
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
                  child: Icon(
                    Icons.tune,
                    color: AppColors.textSecondary,
                    size: context.responsiveIconSize(
                      verySmall: 20,
                      small: 22,
                      large: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showSearch(BuildContext context) {
    // TODO: Implement search functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng tìm kiếm đang được phát triển'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showFilter(BuildContext context) {
    // TODO: Implement filter functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng lọc đang được phát triển'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
