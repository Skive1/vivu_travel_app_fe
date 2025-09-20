import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../injection_container.dart' as di;
import '../widgets/splash_background.dart';
import '../widgets/animated_logo.dart';
import '../widgets/animated_title.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    
    _authBloc = di.sl<AuthBloc>();
    
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
    // Đợi animation chạy một chút rồi mới check auth
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Check auth status
    _authBloc.add(AuthStatusChecked());
  }

  void _navigateBasedOnAuthState(AuthState state) async {
    if (state is AuthAuthenticated) {
      // Token còn hạn → đi đến Home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // Token hết hạn hoặc không có token → check first time user
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('first_time') ?? true;
      
      if (isFirstTime) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
        await prefs.setBool('first_time', false);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return BlocProvider<AuthBloc>(
      create: (context) => _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Khi auth state thay đổi, navigate tương ứng
          if (state is AuthAuthenticated || state is AuthUnauthenticated) {
            _navigateBasedOnAuthState(state);
          }
          // Không cần xử lý AuthLoading vì đang ở splash screen
        },
        child: Scaffold(
          body: SplashBackground(
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
                        const SizedBox(height: 20),
                        AnimatedTitle(
                          controller: _textController,
                        ),
                        const SizedBox(height: 40),
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
    );
  }
}

