import 'package:flutter/material.dart';
import 'package:vivu_travel/features/splash/presentation/widgets/travel_icon.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;
  
  const AnimatedLogo({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final Animation<double> logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));

    return AnimatedBuilder(
      animation: logoAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: logoAnimation.value,
          child: child,
        );
      },
      child: const TravelIcon(),
    );
  }
}
