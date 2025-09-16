import 'package:flutter/material.dart';
import 'package:vivu_travel/features/splash/presentation/widgets/splash_title.dart';

class AnimatedTitle extends StatelessWidget {
  final AnimationController controller;
  
  const AnimatedTitle({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Animation<double> textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: AnimatedBuilder(
        animation: textAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, slideAnimation.value.dy * 20),
            child: Opacity(
              opacity: textAnimation.value,
              child: child,
            ),
          );
        },
        child: const SplashTitle(),
      ),
    );
  }
}