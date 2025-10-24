import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/onboarding_constants.dart';
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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20 + bottomPadding,
          top: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
            
            const SizedBox(height: 20),
            
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