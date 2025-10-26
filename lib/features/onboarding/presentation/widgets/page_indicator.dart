import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        pageCount,
        (index) => _buildDot(index == currentIndex, index, context),
      ),
    );
  }

  Widget _buildDot(bool isActive, int index, BuildContext context) {
    double width;
    Color color;
    
    if (isActive) {
      // Active dot is longer and primary color
      width = context.responsive(
        verySmall: 28.0,
        small: 32.0,
        large: 35.0,
      );
      color = AppColors.primary;
    } else {
      // Inactive dots are smaller and light blue
      width = index == 0 && currentIndex == 1 
          ? context.responsive(
              verySmall: 10.0,
              small: 11.5,
              large: 13.0,
            )
          : context.responsive(
              verySmall: 5.0,
              small: 5.5,
              large: 6.0,
            );
      color = AppColors.primary;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: context.responsive(
          verySmall: 1.5,
          small: 1.8,
          large: 2.0,
        ),
      ),
      height: context.responsive(
        verySmall: 5.5,
        small: 6.0,
        large: 7.0,
      ),
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          context.responsiveBorderRadius(
            verySmall: 12.0,
            small: 14.0,
            large: 16.0,
          ),
        ),
      ),
    );
  }
}
