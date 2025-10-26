import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsiveMargin(vertical: 8, horizontal: 16),
      padding: context.responsivePadding(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withValues(alpha: 0.1),
            blurRadius: context.responsiveElevation(verySmall: 6, small: 7, large: 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: context.responsivePadding(all: 8),
            child: ClipOval(
              child: Image.asset(
                'assets/images/ai_avt.png',
                width: context.responsiveIconSize(verySmall: 20, small: 22, large: 24),
                height: context.responsiveIconSize(verySmall: 20, small: 22, large: 24),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Text(
            'AI đang soạn tin nhắn',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
          Row(
            children: [
              _buildDot(0),
              SizedBox(width: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
              _buildDot(1),
              SizedBox(width: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
              _buildDot(2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final animationValue = (_controller.value - (index * 0.2)).clamp(0.0, 1.0);
        final opacity = (animationValue * 2 - 1).abs();
        
        return Container(
          width: context.responsiveIconSize(verySmall: 6, small: 7, large: 8),
          height: context.responsiveIconSize(verySmall: 6, small: 7, large: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
