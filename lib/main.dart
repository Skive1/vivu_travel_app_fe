import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'routes.dart';
import 'injection_container.dart' as di;
import 'core/constants/app_strings.dart';
import 'core/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize dependencies
  await di.init();
  
  runApp(const VivuTravelApp());
}

class VivuTravelApp extends StatelessWidget {
  const VivuTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: AppColors.primarySwatch,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash, // Start with splash screen
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
