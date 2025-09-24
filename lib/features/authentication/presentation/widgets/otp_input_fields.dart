import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'otp_input_field.dart';

class OtpInputFields extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onOtpComplete;

  const OtpInputFields({
    super.key,
    required this.controller,
    this.onOtpComplete,
  });

  @override
  State<OtpInputFields> createState() => _OtpInputFieldsState();
}

class _OtpInputFieldsState extends State<OtpInputFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // OTP Code Label
        const Text(
          'OTP Code',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return OtpInputField(
              controller: widget.controller.otpControllers[index],
              focusNode: widget.controller.otpFocusNodes[index],
              onChanged: (value) {
                widget.controller.handleOtpChange(value, index);
                if (widget.controller.isOtpComplete() && widget.onOtpComplete != null) {
                  widget.onOtpComplete!();
                }
                setState(() {}); // Rebuild to update button state
              },
              onBackspace: () => widget.controller.handleBackspace(index),
            );
          }),
        ),
      ],
    );
  }
}
