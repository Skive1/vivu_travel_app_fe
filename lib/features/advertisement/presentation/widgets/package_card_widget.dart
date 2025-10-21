import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/package_entity.dart';

class PackageCardWidget extends StatelessWidget {
  final PackageEntity package;
  final VoidCallback onTap;
  final VoidCallback onPurchase;

  const PackageCardWidget({
    super.key,
    required this.package,
    required this.onTap,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            context.responsiveBorderRadius(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.responsive(
                verySmall: 4.0,
                small: 6.0,
                large: 8.0,
              ),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Container(
              padding: context.responsivePadding(
                horizontal: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 28.0,
                ),
                vertical: context.responsive(
                  verySmall: 16.0,
                  small: 18.0,
                  large: 20.0,
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: package.isActive 
                      ? [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.05),
                        ]
                      : [
                          Colors.grey.withValues(alpha: 0.1),
                          Colors.grey.withValues(alpha: 0.05),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(
                    context.responsiveBorderRadius(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: package.isActive 
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      size: context.responsiveIconSize(
                        verySmall: 18.0,
                        small: 20.0,
                        large: 22.0,
                      ),
                      color: package.isActive ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  SizedBox(
                    width: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.name,
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 18.0,
                              small: 20.0,
                              large: 22.0,
                            ),
                            fontWeight: FontWeight.w700,
                            color: package.isActive 
                                ? AppColors.textPrimary 
                                : Colors.grey,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(
                          height: context.responsiveSpacing(
                            verySmall: 4.0,
                            small: 6.0,
                            large: 8.0,
                          ),
                        ),
                        Text(
                          'Gói dịch vụ',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 12.0,
                              small: 13.0,
                              large: 14.0,
                            ),
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: context.responsivePadding(
                      horizontal: context.responsive(
                        verySmall: 12.0,
                        small: 14.0,
                        large: 16.0,
                      ),
                      vertical: context.responsive(
                        verySmall: 6.0,
                        small: 8.0,
                        large: 10.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: package.isActive 
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF10B981),
                                Color(0xFF059669),
                              ],
                            )
                          : const LinearGradient(
                              colors: [
                                Colors.grey,
                                Color(0xFF6B7280),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: package.isActive 
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : Colors.grey.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      package.isActive ? 'Hoạt động' : 'Tạm dừng',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 12.0,
                          small: 13.0,
                          large: 14.0,
                        ),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: context.responsivePadding(
                all: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 28.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    package.description,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(
                        verySmall: 14.0,
                        small: 15.0,
                        large: 16.0,
                      ),
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                  ),
                  
                  // Features
                  _buildFeatureRow(
                    context,
                    Icons.article_outlined,
                    'Số bài đăng tối đa',
                    '${package.maxPostCount} bài',
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
                    ),
                  ),
                  
                  _buildFeatureRow(
                    context,
                    Icons.schedule,
                    'Thời hạn',
                    '${package.durationInDays} ngày',
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 16.0,
                      small: 20.0,
                      large: 24.0,
                    ),
                  ),
                  
                  // Price and Purchase Button
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Giá',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 12.0,
                                  small: 13.0,
                                  large: 14.0,
                                ),
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(
                              height: context.responsiveSpacing(
                                verySmall: 4.0,
                                small: 6.0,
                                large: 8.0,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(package.price),
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 20.0,
                                  small: 22.0,
                                  large: 24.0,
                                ),
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: context.responsiveSpacing(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: package.isActive ? onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: package.isActive 
                              ? AppColors.primary 
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: context.responsivePadding(
                            horizontal: context.responsive(
                              verySmall: 20.0,
                              small: 24.0,
                              large: 28.0,
                            ),
                            vertical: context.responsive(
                              verySmall: 12.0,
                              small: 14.0,
                              large: 16.0,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: context.responsiveIconSize(
                                verySmall: 16.0,
                                small: 18.0,
                                large: 20.0,
                              ),
                            ),
                            SizedBox(
                              width: context.responsiveSpacing(
                                verySmall: 6.0,
                                small: 8.0,
                                large: 10.0,
                              ),
                            ),
                            Text(
                              package.isActive ? 'Mua ngay' : 'Tạm dừng',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 14.0,
                                  small: 15.0,
                                  large: 16.0,
                                ),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: context.responsiveIconSize(
              verySmall: 16.0,
              small: 18.0,
              large: 20.0,
            ),
            color: AppColors.primary,
          ),
        ),
        SizedBox(
          width: context.responsiveSpacing(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 14.0,
              small: 15.0,
              large: 16.0,
            ),
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
