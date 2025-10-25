import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/responsive_utils.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isSmallScreen;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    // Get responsive values using ResponsiveUtils
    final borderRadius = context.responsiveBorderRadius(
      verySmall: 16.0,
      small: 20.0,
      large: 24.0,
    );
    final shadowBlur = context.responsive(
      verySmall: 12.0,
      small: 16.0,
      large: 20.0,
    );
    final shadowOffset = context.responsive(
      verySmall: -3.0,
      small: -4.0,
      large: -5.0,
    );
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: shadowBlur,
            offset: Offset(0, shadowOffset),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: context.responsivePadding(
            horizontal: context.responsive(verySmall: 6.0, small: 8.0, large: 12.0),
            vertical: context.responsive(verySmall: 4.0, small: 6.0, large: 8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Trang chủ',
                index: 0,
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Khám phá',
                index: 1,
                isActive: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today,
                label: 'Kế hoạch',
                index: 2,
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.smart_toy_outlined,
                activeIcon: Icons.smart_toy,
                label: 'Chatbot',
                index: 3,
                isActive: currentIndex == 3,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Hồ sơ',
                index: 4,
                isActive: currentIndex == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    // Get responsive values using ResponsiveUtils
    final verticalPadding = context.responsive(verySmall: 3.0, small: 4.0, large: 6.0);
    final horizontalPadding = context.responsive(verySmall: 4.0, small: 6.0, large: 8.0);
    final horizontalMargin = context.responsive(verySmall: 1.0, small: 2.0, large: 4.0);
    final borderRadius = context.responsiveBorderRadius(
      verySmall: 10.0,
      small: 12.0,
      large: 16.0,
    );
    final iconBorderRadius = context.responsiveBorderRadius(
      verySmall: 6.0,
      small: 8.0,
      large: 12.0,
    );
    final iconPadding = isActive 
        ? context.responsive(verySmall: 1.5, small: 2.0, large: 3.0)
        : 0.0;
    
    // Icon sizes
    final activeIconSize = context.responsiveIconSize(
      verySmall: 18.0,
      small: 20.0,
      large: 24.0,
    );
    final inactiveIconSize = context.responsiveIconSize(
      verySmall: 16.0,
      small: 18.0,
      large: 22.0,
    );
    
    // Font sizes
    final activeFontSize = context.responsiveFontSize(
      verySmall: 9.0,
      small: 10.0,
      large: 12.0,
    );
    final inactiveFontSize = context.responsiveFontSize(
      verySmall: 8.0,
      small: 9.0,
      large: 11.0,
    );
    
    // Spacing
    final spacing = context.responsiveSpacing(
      verySmall: 1.0,
      small: 2.0,
      large: 4.0,
    );
    
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: context.responsivePadding(
            vertical: verticalPadding, 
            horizontal: horizontalPadding
          ),
          margin: context.responsiveMargin(horizontal: horizontalMargin),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  size: isActive ? activeIconSize : inactiveIconSize,
                ),
              ),
              SizedBox(height: spacing),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isActive ? activeFontSize : inactiveFontSize,
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
