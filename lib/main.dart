import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

import 'injection_container.dart' as di;
import 'routes.dart';
import 'core/constants/app_colors.dart';
import 'core/utils/dialog_utils.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  await di.init();
  
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => di.sl<AuthBloc>()..add(AuthStatusChecked()),
      child: MaterialApp(
        title: 'Vivu Travel',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
        ),
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              // Show error dialog for auth errors
              DialogUtils.showErrorDialog(
                context: context,
                title: 'Authentication Error',
                message: state.message,
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading || state is AuthInitial) {
              // Show splash screen while checking auth status
              return const Scaffold(
                backgroundColor: AppColors.primary,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vivu Travel',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              // User is logged in, go to home
              return Navigator(
                initialRoute: AppRoutes.home,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            } else {
              // User not logged in, show onboarding/login flow
              return Navigator(
                initialRoute: AppRoutes.splash,
                onGenerateRoute: AppRoutes.generateRoute,
              );
            }
          },
        ),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
