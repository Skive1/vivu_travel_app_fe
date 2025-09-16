import 'package:flutter/material.dart';
import '../../domain/entities/onboard_entity.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardEntity onboardData;

  const OnboardingPageWidget({
    super.key,
    required this.onboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _hexToColor(onboardData.backgroundColor),
            _hexToColor(onboardData.backgroundColor).withOpacity(0.8),
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // Illustration
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Image.asset(
                  onboardData.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        _getIconForPage(),
                        size: 120,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      onboardData.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      onboardData.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getIconForPage() {
    switch (onboardData.title) {
      case 'Khám Phá Thế Giới':
        return Icons.explore;
      case 'Lên Kế Hoạch Dễ Dàng':
        return Icons.event_note;
      case 'Chia Sẻ Trải Nghiệm':
        return Icons.share;
      default:
        return Icons.travel_explore;
    }
  }
}
