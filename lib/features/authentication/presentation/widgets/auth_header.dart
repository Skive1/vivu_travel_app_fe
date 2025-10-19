import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showBackButton) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: onBackPressed ?? () => Navigator.pop(context),
                child: Container(
                  width: context.responsive(
                    verySmall: 36.0,
                    small: 40.0,
                    large: 44.0,
                  ),
                  height: context.responsive(
                    verySmall: 36.0,
                    small: 40.0,
                    large: 44.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Colors.grey[100] equivalent
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                      verySmall: 8.0,
                      small: 10.0,
                      large: 12.0,
                    )),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: const Color(0xFF1A1A1A),
                    size: context.responsiveIconSize(
                      verySmall: 16.0,
                      small: 18.0,
                      large: 20.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.responsiveSpacing(
              verySmall: 16.0,
              small: 20.0,
              large: 24.0,
            )),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 24.0,
                small: 28.0,
                large: 32.0,
              ),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: context.responsiveSpacing(
            verySmall: 6.0,
            small: 7.0,
            large: 8.0,
          )),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              color: const Color(0xFF757575), // Colors.grey[600] equivalent
            ),
          ),
        ],
      ),
    );
  }
}
