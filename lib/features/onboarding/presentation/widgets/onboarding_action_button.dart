import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingActionButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onPressed;

  const OnboardingActionButton({
    super.key,
    required this.isLastPage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.responsive(
        verySmall: 48.0,
        small: 52.0,
        large: 56.0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.responsiveBorderRadius(
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          isLastPage ? AppStrings.getStarted : AppStrings.next,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 14.0,
              small: 15.0,
              large: 16.0,
            ),
            fontWeight: FontWeight.w600,
            fontFamily: 'SF UI Display',
          ),
        ),
      ),
    );
  }
}