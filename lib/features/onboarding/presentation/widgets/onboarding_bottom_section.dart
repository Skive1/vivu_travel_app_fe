import 'package:flutter/material.dart';
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
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 40,
          top: 20,
        ),
        child: SafeArea(
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
              
              const SizedBox(height: 40),
              
              // Action button (Next/Get Started)
              OnboardingActionButton(
                isLastPage: isLastPage,
                onPressed: isLastPage ? onGetStartedPressed : onNextPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}