import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_screen_layout.dart';
import '../widgets/otp_verification_form.dart';

class OtpVerificationResetPasswordScreen extends StatefulWidget {
  final String email;
  
  const OtpVerificationResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationResetPasswordScreen> createState() => _OtpVerificationResetPasswordScreenState();
}

class _OtpVerificationResetPasswordScreenState extends State<OtpVerificationResetPasswordScreen> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() {
    _authController.handleVerifyResetPasswordOtp(context, widget.email);
  }

  void _handleResendOtp() {
    _authController.handleResendResetPasswordOtp(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ResetPasswordOtpVerificationSuccess) {
          _authController.navigateToResetPassword(
            context, 
            state.resetTokenEntity.resetToken,
          );
        } else if (state is AuthError) {
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Verification Failed',
            message: state.message,
          );
        }
      },
      child: AuthScreenLayout(
        title: 'OTP Verification',
        subtitle: '',
        child: OtpVerificationForm(
          controller: _authController,
          email: widget.email,
          onVerify: _handleVerifyOtp,
          onResend: _handleResendOtp,
        ),
      ),
    );
  }
}
