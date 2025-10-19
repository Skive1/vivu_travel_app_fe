import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(
          all: context.responsive(
            verySmall: 24.0,
            small: 32.0,
            large: 40.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: context.responsiveIconSize(
                verySmall: 64.0,
                small: 72.0,
                large: 80.0,
              ),
              color: Colors.grey[400],
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16.0,
                small: 20.0,
                large: 24.0,
              ),
            ),
            
            Text(
              title,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 18.0,
                  small: 20.0,
                  large: 22.0,
                ),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 8.0,
                small: 12.0,
                large: 16.0,
              ),
            ),
            
            Text(
              subtitle,
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 15.0,
                  large: 16.0,
                ),
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (actionText != null && onAction != null) ...[
              SizedBox(
                height: context.responsiveSpacing(
                  verySmall: 24.0,
                  small: 28.0,
                  large: 32.0,
                ),
              ),
              
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: context.responsivePadding(
                    horizontal: context.responsive(
                      verySmall: 24.0,
                      small: 28.0,
                      large: 32.0,
                    ),
                    vertical: context.responsive(
                      verySmall: 12.0,
                      small: 14.0,
                      large: 16.0,
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
                  actionText!,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 14.0,
                      small: 15.0,
                      large: 16.0,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
