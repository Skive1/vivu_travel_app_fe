import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFAD5E1), // Pink background
      ),
      child: Stack(
        children: [
          // Main character
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CustomPaint(
                painter: AvatarPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Face
    paint.color = const Color(0xFFFFDBD7);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.25,
      paint,
    );
    
    // Hair
    paint.color = const Color(0xFF2D1B2E);
    final hairPath = Path();
    hairPath.addOval(Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.25),
      width: size.width * 0.45,
      height: size.height * 0.35,
    ));
    canvas.drawPath(hairPath, paint);
    
    // Shirt - Orange/Red
    paint.color = const Color(0xFFFF6B35);
    final shirtRect = Rect.fromLTWH(
      size.width * 0.3,
      size.height * 0.55,
      size.width * 0.4,
      size.height * 0.35,
    );
    canvas.drawRect(shirtRect, paint);
    
    // Shirt collar - Blue
    paint.color = const Color(0xFF4A90E2);
    final collarPath = Path();
    collarPath.moveTo(size.width * 0.35, size.height * 0.55);
    collarPath.lineTo(size.width * 0.5, size.height * 0.65);
    collarPath.lineTo(size.width * 0.65, size.height * 0.55);
    collarPath.lineTo(size.width * 0.6, size.height * 0.5);
    collarPath.lineTo(size.width * 0.4, size.height * 0.5);
    collarPath.close();
    canvas.drawPath(collarPath, paint);
    
    // Eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.38),
      2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.58, size.height * 0.38),
      2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}