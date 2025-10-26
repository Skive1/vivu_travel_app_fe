import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../controllers/otp_controller.dart';

class OtpResendSection extends StatefulWidget {
  final OtpController controller;
  final VoidCallback onResend;

  const OtpResendSection({
    super.key,
    required this.controller,
    required this.onResend,
  });

  @override
  State<OtpResendSection> createState() => _OtpResendSectionState();
}

class _OtpResendSectionState extends State<OtpResendSection> {
  @override
  void initState() {
    super.initState();
    // Listen to timer updates
    widget.controller.startResendTimer(onUpdate: () {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Resend code to ',
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 12.0,
              small: 13.0,
              large: 14.0,
            ),
            color: const Color(0xFF757575),
          ),
        ),
        if (widget.controller.canResend)
          GestureDetector(
            onTap: () {
              widget.onResend();
              setState(() {});
            },
            child: Text(
              'Resend',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 12.0,
                  small: 13.0,
                  large: 14.0,
                ),
                color: const Color(0xFF24BAEC),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            '${widget.controller.resendCountdown.toString().padLeft(2, '0')}s',
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 12.0,
                small: 13.0,
                large: 14.0,
              ),
              color: const Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
