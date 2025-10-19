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
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
                ),
                vertical: context.responsive(
                  verySmall: 8.0,
                  small: 10.0,
                  large: 12.0,
                ),
              ),
              decoration: BoxDecoration(
                color: package.isActive 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
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
                  Icon(
                    Icons.card_giftcard,
                    size: context.responsiveIconSize(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                    color: package.isActive ? AppColors.primary : Colors.grey,
                  ),
                  SizedBox(
                    width: context.responsiveSpacing(
                      verySmall: 8.0,
                      small: 10.0,
                      large: 12.0,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      package.name,
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 16.0,
                          small: 17.0,
                          large: 18.0,
                        ),
                        fontWeight: FontWeight.w600,
                        color: package.isActive 
                            ? AppColors.primary 
                            : Colors.grey,
                      ),
                    ),
                  ),
                  Container(
                    padding: context.responsivePadding(
                      horizontal: context.responsive(
                        verySmall: 6.0,
                        small: 8.0,
                        large: 10.0,
                      ),
                      vertical: context.responsive(
                        verySmall: 2.0,
                        small: 3.0,
                        large: 4.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: package.isActive 
                          ? AppColors.primary 
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(
                        context.responsiveBorderRadius(
                          verySmall: 8.0,
                          small: 10.0,
                          large: 12.0,
                        ),
                      ),
                    ),
                    child: Text(
                      package.isActive ? 'Hoạt động' : 'Tạm dừng',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(
                          verySmall: 10.0,
                          small: 11.0,
                          large: 12.0,
                        ),
                        fontWeight: FontWeight.w600,
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
                  verySmall: 12.0,
                  small: 14.0,
                  large: 16.0,
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
                        verySmall: 13.0,
                        small: 14.0,
                        large: 15.0,
                      ),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  
                  SizedBox(
                    height: context.responsiveSpacing(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
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
                      verySmall: 6.0,
                      small: 8.0,
                      large: 10.0,
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
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
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
                              ),
                            ),
                            SizedBox(
                              height: context.responsiveSpacing(
                                verySmall: 2.0,
                                small: 4.0,
                                large: 6.0,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(
                                locale: 'vi_VN',
                                symbol: '₫',
                              ).format(package.price),
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 18.0,
                                  small: 20.0,
                                  large: 22.0,
                                ),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: package.isActive ? onPurchase : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: context.responsivePadding(
                            horizontal: context.responsive(
                              verySmall: 16.0,
                              small: 20.0,
                              large: 24.0,
                            ),
                            vertical: context.responsive(
                              verySmall: 8.0,
                              small: 10.0,
                              large: 12.0,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.responsiveBorderRadius(
                                verySmall: 8.0,
                                small: 10.0,
                                large: 12.0,
                              ),
                            ),
                          ),
                        ),
                        child: Text(
                          package.isActive ? 'Mua ngay' : 'Tạm dừng',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(
                              verySmall: 12.0,
                              small: 13.0,
                              large: 14.0,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
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
        Icon(
          icon,
          size: context.responsiveIconSize(
            verySmall: 14.0,
            small: 16.0,
            large: 18.0,
          ),
          color: AppColors.textSecondary,
        ),
        SizedBox(
          width: context.responsiveSpacing(
            verySmall: 8.0,
            small: 10.0,
            large: 12.0,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 12.0,
              small: 13.0,
              large: 14.0,
            ),
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 12.0,
              small: 13.0,
              large: 14.0,
            ),
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
