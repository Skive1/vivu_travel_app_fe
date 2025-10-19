import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? placeholder;
  final bool obscureText;
  final bool isPassword; // Thêm cho tương thích ngược
  final bool isPasswordVisible; // Thêm cho tương thích ngược
  final VoidCallback? onTogglePassword; // Thêm cho tương thích ngược
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  
  const AuthTextField({
    super.key,
    required this.controller,
    this.label,
    this.placeholder,
    this.obscureText = false,
    this.isPassword = false, // Default false
    this.isPasswordVisible = false, // Default false
    this.onTogglePassword,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Logic để xác định obscureText và suffixIcon
    final bool shouldObscure = isPassword ? !isPasswordVisible : obscureText;
    
    Widget? finalSuffixIcon = suffixIcon;
    
    // Nếu là password field và có callback, tạo toggle icon
    if (isPassword && onTogglePassword != null) {
      finalSuffixIcon = IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: const Color(0xFF757575),
          size: context.responsiveIconSize(
            verySmall: 18.0,
            small: 20.0,
            large: 22.0,
          ),
        ),
        onPressed: onTogglePassword,
        padding: context.responsivePadding(
          all: context.responsive(
            verySmall: 8.0,
            small: 10.0,
            large: 12.0,
          ),
        ),
        constraints: context.responsive(
          verySmall: BoxConstraints(
            minWidth: 32.0,
            minHeight: 32.0,
          ),
          small: BoxConstraints(
            minWidth: 36.0,
            minHeight: 36.0,
          ),
          large: BoxConstraints(
            minWidth: 40.0,
            minHeight: 40.0,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: context.responsiveSpacing(
            verySmall: 6.0,
            small: 7.0,
            large: 8.0,
          )),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: shouldObscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(
              color: const Color(0xFF9E9E9E),
              fontSize: context.responsiveFontSize(
                verySmall: 14.0,
                small: 15.0,
                large: 16.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              )),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              )),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              )),
              borderSide: const BorderSide(color: Color(0xFF24BAEC), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              )),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                verySmall: 8.0,
                small: 10.0,
                large: 12.0,
              )),
              borderSide: const BorderSide(color: Color(0xFFE53E3E), width: 2),
            ),
            suffixIcon: finalSuffixIcon,
            contentPadding: context.responsivePadding(
              horizontal: context.responsive(
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
              vertical: context.responsive(
                verySmall: 12.0,
                small: 14.0,
                large: 16.0,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}