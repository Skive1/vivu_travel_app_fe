import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  
  const AuthButton({
    super.key,
    required this.text,
    required this.isLoading,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.responsive(
        verySmall: 48.0,
        small: 52.0,
        large: 56.0,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF24BAEC),
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
              verySmall: 8.0,
              small: 10.0,
              large: 12.0,
            )),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: context.responsive(
                  verySmall: 20.0,
                  small: 22.0,
                  large: 24.0,
                ),
                height: context.responsive(
                  verySmall: 20.0,
                  small: 22.0,
                  large: 24.0,
                ),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(
                    verySmall: 14.0,
                    small: 15.0,
                    large: 16.0,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}