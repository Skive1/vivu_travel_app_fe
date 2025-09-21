import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF24BAEC);
  static const Color primaryLight = Color(0xFF5AA3C1);
  static const Color primaryDark = Color(0xFF1B5A7A);

  // Secondary colors
  static const Color secondary = Color(0xFFF24236);
  static const Color secondaryLight = Color(0xFFF56B5F);
  static const Color secondaryDark = Color(0xFFB71C1C);

  // Accent colors
  static const Color accent = Color(0xFFF6AE2D);
  static const Color accentLight = Color(0xFFF8C555);
  static const Color accentDark = Color(0xFFD4941B);
  static const Color accentOrange = Color.fromARGB(255, 255, 115, 0);
  
  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF121212);
  static const Color onBackground = Color(0xFF121212);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);

  // Input colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocused = Color(0xFF24BAEC);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color bgColor = Color(0xFFF8F9FA);

  static const bellBackground = Color(0xFFF7F7F9);

  static const MaterialColor primarySwatch =
      MaterialColor(0xFF2E86AB, <int, Color>{
        50: Color(0xFFE6F3F8),
        100: Color(0xFFC0E1ED),
        200: Color(0xFF96CDE1),
        300: Color(0xFF6CB9D5),
        400: Color(0xFF4DAACC),
        500: Color(0xFF2E86AB),
        600: Color(0xFF297EA4),
        700: Color(0xFF23739A),
        800: Color(0xFF1D6991),
        900: Color(0xFF125680),
      });
}
