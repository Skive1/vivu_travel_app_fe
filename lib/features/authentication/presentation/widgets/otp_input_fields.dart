import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../controllers/otp_controller.dart';
import 'otp_input_field.dart';

class OtpInputFields extends StatefulWidget {
  final OtpController controller;
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
        Text(
          'OTP Code',
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
          verySmall: 12.0,
          small: 14.0,
          large: 16.0,
        )),
        
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
