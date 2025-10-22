import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../widgets/splash_background.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_title.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../notification/presentation/bloc/notification_bloc.dart';
import '../../../notification/presentation/bloc/notification_event.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _startAnimations();
    _initializeApp();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
  }

  void _initializeApp() async {
    // Start auth check immediately, don't wait for animations
    // Animations and auth check can run in parallel for better UX
    await Future.delayed(const Duration(milliseconds: 800)); // Minimal delay for smooth logo appearance
    
    // Initialize SignalR for real-time notifications
    _initializeSignalR();
    
    // Check auth status using global AuthBloc
    if (mounted) {
      context.read<AuthBloc>().add(AuthStatusChecked());
    }
  }

  void _initializeSignalR() {
    try {
      print('🔌 Starting SignalR initialization...');
      
      // Initialize SignalR service
      final notificationBloc = di.sl<NotificationBloc>();
      print('📱 NotificationBloc created successfully');
      
      notificationBloc.add(const InitializeSignalREvent());
      print('✅ InitializeSignalREvent added');
      
      // Start SignalR connection
      notificationBloc.add(const StartSignalREvent());
      print('✅ StartSignalREvent added');
      
    } catch (e) {
      print('❌ Failed to initialize SignalR: $e');
    }
  }

  void _navigateBasedOnAuthState(AuthState state) async {
    if (!mounted) return;
    
    if (state is AuthAuthenticated) {
      // Join user group for personal notifications
      if (state.userEntity != null) {
        _joinUserGroup(state.userEntity!.id);
      }
      
      // Token còn hạn → đi đến Home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // Token hết hạn hoặc không có token → check first time user
      final prefs = di.sl<SharedPreferences>();
      final isFirstTime = prefs.getBool('first_time') ?? true;
      
      if (isFirstTime) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        await prefs.setBool('first_time', false);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  void _joinUserGroup(String userId) {
    try {
      final notificationBloc = di.sl<NotificationBloc>();
      notificationBloc.add(JoinUserGroupEvent(userId: userId));
    } catch (e) {
      print('Failed to join user group: $e');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Khi auth state thay đổi, navigate tương ứng
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          _navigateBasedOnAuthState(state);
        }
        // Không cần xử lý AuthLoading vì đang ở splash screen
      },
      child: Scaffold(
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: SplashBackground(
            child: SafeArea(
              child: Column(
                children: [
                  // Logo centered in the middle of screen
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedLogo(
                            controller: _logoController,
                          ),
                          SizedBox(height: screenSize.height * 0.025),
                          AnimatedTitle(
                            controller: _textController,
                          ),
                          SizedBox(height: screenSize.height * 0.05),
                          // Loading indicator để show đang check auth
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

