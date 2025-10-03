import 'package:flutter/material.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/authentication/presentation/screens/login_screen.dart';
import 'features/authentication/presentation/screens/register_screen.dart';
import 'features/authentication/presentation/screens/otp_verification_screen.dart';
import 'features/authentication/presentation/screens/forgot_password_screen.dart';
import 'features/authentication/presentation/screens/otp_verification_reset_password_screen.dart';
import 'features/authentication/presentation/screens/reset_password_screen.dart';
import 'features/authentication/presentation/screens/change_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/schedule/presentation/screens/schedule_screen.dart';
import 'features/schedule/presentation/screens/schedule_list_screen.dart';
import 'features/schedule/presentation/screens/schedule_detail_screen.dart';
import 'features/user/presentation/screens/profile_screen.dart';
import 'features/user/presentation/screens/profile_detail_screen.dart';
import 'features/user/presentation/screens/edit_profile_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart';
import 'features/user/presentation/bloc/user_bloc.dart';
import 'features/schedule/presentation/bloc/ScheduleBloc.dart';
import 'features/schedule/domain/entities/schedule_entity.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerificationResetPassword = '/otp-verification-reset-password';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String home = '/home';
  static const String schedule = '/schedule';
  static const String scheduleList = '/schedule-list';
  static const String scheduleDetail = '/schedule-detail';
  static const String profile = '/profile';
  static const String profileDetail = '/profile-detail';
  static const String editProfile = '/edit-profile';
  
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
          builder: (_) => OtpVerificationScreen(email: email),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case otpVerificationResetPassword:
        final args = settings.arguments as Map<String, dynamic>;
        final email = args['email'] as String;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationResetPasswordScreen(email: email),
        );

      case resetPassword:
        final resetToken = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(resetToken: resetToken),
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
        );
        
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
        
      case schedule:
        final scheduleId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ScheduleScreen(scheduleId: scheduleId),
        );
        
      case scheduleList:
        final participantId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<ScheduleBloc>(),
            child: ScheduleListScreen(participantId: participantId),
          ),
        );
        
      case scheduleDetail:
        final schedule = settings.arguments as ScheduleEntity;
        return MaterialPageRoute(
          builder: (_) => ScheduleDetailScreen(schedule: schedule),
        );
        
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case profileDetail:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<UserBloc>(),
            child: const ProfileDetailScreen(),
          ),
        );
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => sl<UserBloc>(),
            child: const EditProfileScreen(),
          ),
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
