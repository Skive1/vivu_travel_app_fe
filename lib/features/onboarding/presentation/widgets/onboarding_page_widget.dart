import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/onboard_entity.dart';
import '../../../../core/constants/app_colors.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardEntity onboardData;

  const OnboardingPageWidget({
    super.key,
    required this.onboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Background image - tràn viền trên và bo góc dưới
        Container(
          width: double.infinity,
          height: 510,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.asset(
            onboardData.imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
              );
            },
          ),
        ),
        
        // Content section với background trắng
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Title with styled text
                  _buildStyledTitle(),
                  
                  const SizedBox(height: 8),
                  
                  // Underline decoration
                  _buildUnderlineDecoration(),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    onboardData.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Color(0xFF757575),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTitle() {
    List<String> words = onboardData.title.split(' ');
    List<TextSpan> spans = [];
    
    // Determine which word should be highlighted based on the title
    String highlightWord = '';
    if (onboardData.title.contains('Phá')) {
      highlightWord = 'Phá';
    } else if (onboardData.title.contains('Dễ')) {
      highlightWord = 'Dễ';
    } else if (onboardData.title.contains('Chia')) {
      highlightWord = 'Chia';
    }
    
    for (String word in words) {
      bool isHighlighted = word.toLowerCase().contains(highlightWord.toLowerCase()) && highlightWord.isNotEmpty;
      spans.add(
        TextSpan(
          text: word + ' ',
            style: GoogleFonts.nunitoSans(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? AppColors.accentOrange : Color(0xFF121212),
              height: 1.2,
            ),
        ),
      );
    }
    
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
  
  Widget _buildUnderlineDecoration() {
    // SVG-like underline decoration
    return CustomPaint(
      size: const Size(100, 10),
      painter: UnderlinePainter(),
    );
  }
}

class UnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
