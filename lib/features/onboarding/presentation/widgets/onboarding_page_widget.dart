import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/onboard_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardEntity onboardData;

  const OnboardingPageWidget({
    super.key,
    required this.onboardData,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tính toán kích thước hình ảnh dựa trên tỷ lệ màn hình
    final imageHeight = _calculateResponsiveImageHeight(context, screenHeight);
    final imageWidth = screenWidth;
    
    return Column(
      children: [
        // Background image - tràn viền trên và bo góc dưới
        Container(
          width: double.infinity,
          height: imageHeight + statusBarHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                context.responsiveBorderRadius(
                  verySmall: 24.0,
                  small: 27.0,
                  large: 30.0,
                ),
              ),
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Background image tràn lên status bar
              Positioned(
                top: -statusBarHeight,
                left: 0,
                right: 0,
                height: imageHeight + statusBarHeight,
                child: _buildResponsiveImage(context, imageWidth, imageHeight + statusBarHeight),
              ),
            ],
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
              padding: context.responsivePadding(
                horizontal: context.responsive(
                  verySmall: 20.0,
                  small: 24.0,
                  large: 27.0,
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: context.responsiveWithTall(
                      verySmall: 24.0,
                      small: 28.0,
                      large: 32.0,
                      tall: 20.0, // Giảm spacing cho tall phones
                    ),
                  ),
                  
                  // Title with styled text
                  _buildStyledTitle(context),
                  
                  SizedBox(
                    height: context.responsiveWithTall(
                      verySmall: 4.0,
                      small: 5.0,
                      large: 6.0,
                      tall: 3.0, // Giảm spacing cho tall phones
                    ),
                  ),
                  
                  // Underline decoration
                  _buildUnderlineDecoration(context),
                  
                  SizedBox(
                    height: context.responsiveWithTall(
                      verySmall: 8.0,
                      small: 10.0,
                      large: 12.0,
                      tall: 6.0, // Giảm spacing cho tall phones
                    ),
                  ),
                  
                  // Description
                  Text(
                    onboardData.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: context.responsiveWithTall(
                        verySmall: 14.0,
                        small: 15.0,
                        large: 16.0,
                        tall: 15.0, // Giảm nhẹ font size cho tall phones
                      ),
                      color: Color(0xFF757575),
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTitle(BuildContext context) {
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
              fontSize: context.responsiveWithTall(
                verySmall: 30.0,
                small: 33.0,
                large: 36.0,
                tall: 32.0, // Giảm nhẹ font size cho tall phones
              ),
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
  
  Widget _buildUnderlineDecoration(BuildContext context) {
    // SVG-like underline decoration
    return CustomPaint(
      size: Size(
        context.responsiveWithTall(
          verySmall: 80.0,
          small: 90.0,
          large: 100.0,
          tall: 85.0, // Giảm nhẹ width cho tall phones
        ),
        context.responsiveWithTall(
          verySmall: 8.0,
          small: 9.0,
          large: 10.0,
          tall: 8.5, // Giảm nhẹ height cho tall phones
        ),
      ),
      painter: UnderlinePainter(),
    );
  }

  /// Tính toán chiều cao hình ảnh responsive dựa trên Material Design breakpoints
  /// Điện thoại 720px thuộc category "Ultra-large phone" (430-480dp)
  double _calculateResponsiveImageHeight(BuildContext context, double screenHeight) {
    // Tính toán dựa trên breakpoints Material Design
    double percentage;
    double minHeight;
    double maxHeight;
    
    if (context.isVerySmallPhone) {
      // ≤320dp: iPhone SE
      percentage = 0.50;
      minHeight = 200.0;
      maxHeight = 350.0;
    } else if (context.isSmallPhone) {
      // 320-360dp: iPhone 6/7/8
      percentage = 0.55;
      minHeight = 220.0;
      maxHeight = 380.0;
    } else if (context.isCompactPhone) {
      // 360-374dp: Galaxy S6/S7
      percentage = 0.58;
      minHeight = 240.0;
      maxHeight = 400.0;
    } else if (context.isMediumPhone) {
      // 374-430dp: iPhone 6/7/8 Plus
      percentage = 0.62;
      minHeight = 260.0;
      maxHeight = 450.0;
    } else if (context.isLargePhone) {
      // 430-480dp: Ultra-large phone (điện thoại của bạn 720px)
      percentage = 0.65;
      minHeight = 280.0;
      maxHeight = 480.0;
    } else if (context.isSmallTablet) {
      // 480-600dp: Small tablet/phablet
      percentage = 0.70;
      minHeight = 300.0;
      maxHeight = 520.0;
    } else if (context.isTablet) {
      // 600-768dp: Tablet portrait
      percentage = 0.75;
      minHeight = 350.0;
      maxHeight = 600.0;
    } else {
      // 768-1024dp: Tablet landscape
      percentage = 0.80;
      minHeight = 400.0;
      maxHeight = 700.0;
    }
    
    // Điều chỉnh cho tall phones
    if (context.isVeryTallPhone) {
      percentage *= 0.75; // Giảm 25% cho điện thoại rất cao như 720x1612
    } else if (context.isTallPhone) {
      percentage *= 0.85; // Giảm 15% cho điện thoại cao
    }
    
    final calculatedHeight = screenHeight * percentage;
    return calculatedHeight.clamp(minHeight, maxHeight);
  }

  /// Xây dựng hình ảnh responsive với scaling phù hợp
  Widget _buildResponsiveImage(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
            context.responsiveBorderRadius(
              verySmall: 24.0,
              small: 27.0,
              large: 30.0,
            ),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: context.responsiveImageShadowBlur,
            offset: context.responsiveImageShadowOffset,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Main image
          Positioned.fill(
            child: Image.asset(
              onboardData.imagePath,
              fit: context.optimalImageBoxFit,
              alignment: context.optimalImageAlignment,
              errorBuilder: (context, error, stackTrace) {
                return _buildErrorFallback(context, width, height);
              },
            ),
          ),
          
          // Gradient overlay for better text readability (optional)
          if (_shouldShowGradientOverlay(context))
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Kiểm tra có nên hiển thị gradient overlay không
  bool _shouldShowGradientOverlay(BuildContext context) {
    // Chỉ hiển thị gradient trên điện thoại có tỷ lệ cao để cải thiện readability
    return context.isVeryTallPhone || context.isTallPhone;
  }

  /// Xây dựng fallback UI khi hình ảnh lỗi
  Widget _buildErrorFallback(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.8),
            AppColors.primary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
            context.responsiveBorderRadius(
              verySmall: 24.0,
              small: 27.0,
              large: 30.0,
            ),
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.white,
            size: context.responsiveIconSize(
              verySmall: 40.0,
              small: 45.0,
              large: 50.0,
            ),
          ),
          SizedBox(
            height: context.responsiveSpacing(
              verySmall: 8.0,
              small: 10.0,
              large: 12.0,
            ),
          ),
          Text(
            'Không thể tải hình ảnh',
            style: TextStyle(
              color: AppColors.white,
              fontSize: context.responsiveFontSize(
                verySmall: 12.0,
                small: 13.0,
                large: 14.0,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
