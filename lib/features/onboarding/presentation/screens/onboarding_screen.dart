import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/onboarding_constants.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../routes.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/onboarding_skip_button.dart';
import '../widgets/onboarding_bottom_section.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _pageController = PageController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  void _nextPage() {
    if (_currentPage < OnboardingConstants.onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _autoScrollTimer?.cancel();
    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height ,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // PageView with onboarding pages
              _buildPageView(),
              
              // Skip button
              OnboardingSkipButton(onSkip: _skipOnboarding),
              
              // Bottom section with indicators and button
              OnboardingBottomSection(
                currentPage: _currentPage,
                onNextPressed: _nextPage,
                onGetStartedPressed: _navigateToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: OnboardingConstants.onboardingPages.length,
      itemBuilder: (context, index) {
        return OnboardingPageWidget(
          onboardData: OnboardingConstants.onboardingPages[index],
        );
      },
    );
  }
}