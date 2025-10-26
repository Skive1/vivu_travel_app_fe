import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback onBackspace;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.responsive(
        verySmall: 40.0,
        small: 44.0,
        large: 48.0,
      ),
      height: context.responsive(
        verySmall: 48.0,
        small: 52.0,
        large: 56.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
          verySmall: 8.0,
          small: 10.0,
          large: 12.0,
        )),
        border: Border.all(
          color: focusNode.hasFocus ? AppColors.primary : Colors.grey[300]!,
          width: focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: context.responsiveFontSize(
            verySmall: 20.0,
            small: 22.0,
            large: 24.0,
          ),
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A1A1A),
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged,
        onTap: () {
          // Select all text when tapped
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        },
        onFieldSubmitted: (value) {
          if (value.isEmpty) {
            onBackspace();
          }
        },
      ),
    );
  }
}
