import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/onboarding_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'page_indicator.dart';
import 'onboarding_action_button.dart';

class OnboardingBottomSection extends StatelessWidget {
  final int currentPage;
  final VoidCallback onNextPressed;
  final VoidCallback onGetStartedPressed;

  const OnboardingBottomSection({
    super.key,
    required this.currentPage,
    required this.onNextPressed,
    required this.onGetStartedPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == OnboardingConstants.onboardingPages.length - 1;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: context.responsivePadding(
          horizontal: context.responsive(
            verySmall: 16.0,
            small: 18.0,
            large: 20.0,
          ),
          bottom: context.responsive(
            verySmall: 16.0,
            small: 18.0,
            large: 20.0,
          ) + bottomPadding,
          top: context.responsive(
            verySmall: 16.0,
            small: 18.0,
            large: 20.0,
          ),
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              context.responsiveBorderRadius(
                verySmall: 24.0,
                small: 27.0,
                large: 30.0,
              ),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Page indicators centered
            Center(
              child: PageIndicator(
                currentIndex: currentPage,
                pageCount: OnboardingConstants.onboardingPages.length,
              ),
            ),
            
            SizedBox(
              height: context.responsiveSpacing(
                verySmall: 16.0,
                small: 18.0,
                large: 20.0,
              ),
            ),
            
            // Action button (Next/Get Started)
            OnboardingActionButton(
              isLastPage: isLastPage,
              onPressed: isLastPage ? onGetStartedPressed : onNextPressed,
            ),
          ],
        ),
      ),
    );
  }
}