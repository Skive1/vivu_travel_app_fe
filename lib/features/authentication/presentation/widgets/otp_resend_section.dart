import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class OtpResendSection extends StatefulWidget {
  final AuthController controller;
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
        const Text(
          'Resend code to ',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
          ),
        ),
        if (widget.controller.canResend)
          GestureDetector(
            onTap: () {
              widget.onResend();
              setState(() {});
            },
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF24BAEC),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            '${widget.controller.resendCountdown.toString().padLeft(2, '0')}s',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
