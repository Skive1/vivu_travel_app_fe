import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const OnboardingSkipButton({
    super.key,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 20,
      child: TextButton(
        onPressed: onSkip,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: const Text(
          AppStrings.skip,
          style: TextStyle(
            color: AppColors.bgColor,
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: 'Gill Sans MT',
          ),
        ),
      ),
    );
  }
}