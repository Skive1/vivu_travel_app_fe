import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/auth_button.dart';
import '../widgets/otp_input_fields.dart';
import '../widgets/otp_resend_section.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/otp_controller.dart';

class OtpVerificationForm extends StatelessWidget {
  final OtpController controller;
  final String email;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const OtpVerificationForm({
    super.key,
    required this.controller,
    required this.email,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        // Email info text
        Text(
          'Please check your email $email\nto see the verification code',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF757575),
            height: 1.5,
          ),
        ),
        
        SizedBox(height: screenSize.height * 0.06),
        
        // OTP Input Fields
        OtpInputFields(
          controller: controller,
          onOtpComplete: onVerify,
        ),
        
        SizedBox(height: screenSize.height * 0.06),
        
        // Verify Button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              child: AuthButton(
                text: 'Verify',
                isLoading: state is AuthLoading,
                onPressed: controller.isOtpComplete() ? onVerify : () {},
              ),
            );
          },
        ),
        
        const SizedBox(height: 24),
        
        // Resend Section
        OtpResendSection(
          controller: controller,
          onResend: onResend,
        ),
      ],
    );
  }
}
