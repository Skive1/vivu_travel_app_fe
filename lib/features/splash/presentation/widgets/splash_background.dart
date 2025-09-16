import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;
  
  const SplashBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF24BAEC),
      ),
      child: child,
    );
  }
}
