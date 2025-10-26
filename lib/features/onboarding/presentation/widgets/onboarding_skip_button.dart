import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onSkip;

  const OnboardingSkipButton({
    super.key,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + context.responsiveSpacing(
        verySmall: 12.0,
        small: 14.0,
        large: 16.0,
      ),
      right: context.responsive(
        verySmall: 16.0,
        small: 18.0,
        large: 20.0,
      ),
      child: Container(
        padding: context.responsivePadding(
          horizontal: context.responsive(
            verySmall: 10.0,
            small: 11.0,
            large: 12.0,
          ),
          vertical: context.responsive(
            verySmall: 6.0,
            small: 7.0,
            large: 8.0,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(
            context.responsiveBorderRadius(
              verySmall: 16.0,
              small: 18.0,
              large: 20.0,
            ),
          ),
        ),
        child: TextButton(
          onPressed: onSkip,
          style: TextButton.styleFrom(
            padding: context.responsivePadding(
              horizontal: context.responsive(
                verySmall: 6.0,
                small: 7.0,
                large: 8.0,
              ),
              vertical: context.responsive(
                verySmall: 3.0,
                small: 3.5,
                large: 4.0,
              ),
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppStrings.skip,
            style: TextStyle(
              color: AppColors.white,
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              fontWeight: FontWeight.w500,
              fontFamily: 'Gill Sans MT',
            ),
          ),
        ),
      ),
    );
  }
}