import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Vivu Travel',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 40,
        fontWeight: FontWeight.bold,
        height: 1.235,
        letterSpacing: 0.5,
      ),
    );
  }
}