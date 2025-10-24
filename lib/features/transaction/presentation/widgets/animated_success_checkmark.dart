import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class AnimatedSuccessCheckmark extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration animationDuration;

  const AnimatedSuccessCheckmark({
    super.key,
    this.size = 80.0,
    this.color,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<AnimatedSuccessCheckmark> createState() => _AnimatedSuccessCheckmarkState();
}

class _AnimatedSuccessCheckmarkState extends State<AnimatedSuccessCheckmark>
    with TickerProviderStateMixin {
  late AnimationController _circleController;
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _circleController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: Duration(milliseconds: (widget.animationDuration.inMilliseconds * 0.6).round()),
      vsync: this,
    );


    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.elasticOut,
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _circleController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _checkController.forward();
  }

  @override
  void dispose() {
    _circleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkColor = widget.color ?? AppColors.success;
    final responsiveSize = context.responsive(
      verySmall: widget.size * 0.8,
      small: widget.size * 0.9,
      large: widget.size,
    );

    return SizedBox(
      width: responsiveSize,
      height: responsiveSize,
      child: AnimatedBuilder(
        animation: Listenable.merge([_circleController, _checkController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer circle with scale animation
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: responsiveSize,
                  height: responsiveSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: checkColor.withOpacity(0.1),
                    border: Border.all(
                      color: checkColor.withOpacity(0.3),
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
                    color: checkColor,
                    boxShadow: [
                      BoxShadow(
                        color: checkColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Checkmark
              CustomPaint(
                size: Size(responsiveSize, responsiveSize),
                painter: CheckmarkPainter(
                  progress: _checkAnimation.value,
                  color: Colors.white,
                  strokeWidth: 4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CheckmarkPainter({
    required this.progress,
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

    final path = Path();
    
    // Checkmark path
    final startX = size.width * 0.25;
    final startY = size.height * 0.5;
    final middleX = size.width * 0.45;
    final middleY = size.height * 0.65;
    final endX = size.width * 0.75;
    final endY = size.height * 0.35;

    // First line (vertical part)
    final firstLineEndX = startX + (middleX - startX) * progress;
    final firstLineEndY = startY + (middleY - startY) * progress;
    
    path.moveTo(startX, startY);
    path.lineTo(firstLineEndX, firstLineEndY);

    // Second line (horizontal part)
    if (progress > 0.5) {
      final secondLineProgress = (progress - 0.5) * 2;
      final secondLineEndX = middleX + (endX - middleX) * secondLineProgress;
      final secondLineEndY = middleY + (endY - middleY) * secondLineProgress;
      
      path.moveTo(middleX, middleY);
      path.lineTo(secondLineEndX, secondLineEndY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
