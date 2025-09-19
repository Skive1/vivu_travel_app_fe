import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
        (index) => _buildDot(index == currentIndex, index),
      ),
    );
  }

  Widget _buildDot(bool isActive, int index) {
    double width;
    Color color;
    
    if (isActive) {
      // Active dot is longer and primary color
      width = 35;
      color = AppColors.primary;
    } else {
      // Inactive dots are smaller and light blue
      width = index == 0 && currentIndex == 1 ? 13 : 6;
      color = AppColors.primary;
    }
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 7,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
