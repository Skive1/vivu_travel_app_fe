import 'package:flutter/material.dart';

class SplashTitle extends StatelessWidget {
  const SplashTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Vivu Travel',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Geometr415 Blk BT',
        fontSize: 34,
        fontWeight: FontWeight.w400,
        height: 1.235,
        letterSpacing: 0.5,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}