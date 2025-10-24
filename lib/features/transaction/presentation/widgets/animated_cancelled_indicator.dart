import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class AnimatedCancelledIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration animationDuration;

  const AnimatedCancelledIndicator({
    super.key,
    this.size = 80.0,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedCancelledIndicator> createState() => _AnimatedCancelledIndicatorState();
}

class _AnimatedCancelledIndicatorState extends State<AnimatedCancelledIndicator>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    
    _circleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _shakeController.repeat(reverse: true, period: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 300));
    _shakeController.stop();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.color ?? AppColors.error;
    final responsiveSize = context.responsive(
      verySmall: widget.size * 0.8,
      small: widget.size * 0.9,
      large: widget.size,
    );

    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_circleController, _shakeController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle
              Transform.scale(
                scale: _scaleAnimation.value,
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
              
              // X icon with shake animation
              Transform.translate(
                offset: Offset(_shakeAnimation.value * 5, 0),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: CustomPaint(
                    size: Size(responsiveSize, responsiveSize),
                    painter: XMarkPainter(
                      color: Colors.white,
                      strokeWidth: 4,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class XMarkPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  XMarkPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.25;

    // Draw X mark
    canvas.drawLine(
      Offset(centerX - radius, centerY - radius),
      Offset(centerX + radius, centerY + radius),
      paint,
    );
    
    canvas.drawLine(
      Offset(centerX + radius, centerY - radius),
      Offset(centerX - radius, centerY + radius),
      paint,
    );
  }

  @override
  bool shouldRepaint(XMarkPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
