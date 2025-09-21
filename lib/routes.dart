import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/authentication/presentation/screens/otp_verification_screen.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import 'injection_container.dart' as di;

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String profile = '/profile';
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
        
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        );
        
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
        
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
        
      case otpVerification:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => di.sl<AuthBloc>(),
            child: OtpVerificationScreen(email: email),
          ),
        );
        
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
        
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
