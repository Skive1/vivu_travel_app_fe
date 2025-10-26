import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';

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

    return Column(
      children: [
        // Email info text
        Text(
          'Please check your email $email\nto see the verification code',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.responsiveFontSize(
              verySmall: 14.0,
              small: 15.0,
              large: 16.0,
            ),
            color: const Color(0xFF757575),
            height: 1.5,
          ),
        ),
        
        SizedBox(height: context.responsiveSpacing(
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        )),
        
        // OTP Input Fields
        OtpInputFields(
          controller: controller,
          onOtpComplete: onVerify,
        ),
        
        SizedBox(height: context.responsiveSpacing(
          verySmall: 20.0,
          small: 24.0,
          large: 28.0,
        )),
        
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
        
        SizedBox(height: context.responsiveSpacing(
          verySmall: 16.0,
          small: 20.0,
          large: 24.0,
        )),
        
        // Resend Section
        OtpResendSection(
          controller: controller,
          onResend: onResend,
        ),
      ],
    );
  }
}
