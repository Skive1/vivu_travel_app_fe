import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class AnimatedPendingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration animationDuration;

  const AnimatedPendingIndicator({
    super.key,
    this.size = 80.0,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedPendingIndicator> createState() => _AnimatedPendingIndicatorState();
}

class _AnimatedPendingIndicatorState extends State<AnimatedPendingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _circleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _circleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.color ?? AppColors.warning;
    final responsiveSize = context.responsive(
      verySmall: widget.size * 0.8,
      small: widget.size * 0.9,
      large: widget.size,
    );

    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_circleController, _pulseController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulsing circle
              Transform.scale(
                scale: _scaleAnimation.value * _pulseAnimation.value,
                child: Container(
                  width: responsiveSize,
                  height: responsiveSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColor.withOpacity(0.1),
                    border: Border.all(
                      color: indicatorColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              // Inner circle
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: responsiveSize * 0.8,
                  height: responsiveSize * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: indicatorColor,
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Clock icon
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  Icons.access_time,
                  color: Colors.white,
                  size: responsiveSize * 0.4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
