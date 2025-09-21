import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

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
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A1A1A),
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
