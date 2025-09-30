import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Controller for OTP verification functionality
/// Handles OTP input, validation, and resend logic
class OtpController {
  // OTP controllers and state
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  
  final List<FocusNode> otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _resendTimer;
  int resendCountdown = 60;
  bool canResend = false;

  Timer? get resendTimer => _resendTimer;

  VoidCallback? _uiUpdateCallback;

  /// Start resend countdown timer
  void startResendTimer({VoidCallback? onUpdate}) {
    _uiUpdateCallback = onUpdate;
    canResend = false;
    resendCountdown = 60;
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCountdown == 0) {
        canResend = true;
        timer.cancel();
      } else {
        resendCountdown--;
      }
      _uiUpdateCallback?.call(); // Update UI
    });
  }

  /// Cancel resend timer
  void cancelResendTimer() {
    _resendTimer?.cancel();
  }

  /// Get complete OTP code
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// Check if OTP is complete
  bool isOtpComplete() {
    return getOtpCode().length == 6;
  }

  /// Handle OTP input change
  void handleOtpChange(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
  }

  /// Handle backspace in OTP input
  void handleBackspace(int index) {
    if (index > 0 && otpControllers[index].text.isEmpty) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  /// Validate OTP code
  String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.otpRequired;
    }
    
    if (value.length != ValidationConstants.otpLength) {
      return ValidationMessages.otpIncomplete;
    }
    
    if (!RegExp(ValidationConstants.otpPattern).hasMatch(value)) {
      return ValidationMessages.otpInvalid;
    }
    
    return null;
  }

  /// Handle OTP verification for registration
  void handleVerifyRegisterOtp(BuildContext context, String email) {
    final otpCode = getOtpCode();
    final validationError = validateOtp(otpCode);
    
    if (validationError != null) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Invalid OTP',
        message: validationError,
      );
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(VerifyRegisterOtpRequested(
      email: email,
      otpCode: otpCode,
    ));
  }

  /// Handle OTP verification for password reset
  void handleVerifyResetPasswordOtp(BuildContext context, String email) {
    final otpCode = getOtpCode();
    final validationError = validateOtp(otpCode);
    if (validationError != null) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Invalid OTP',
        message: validationError,
      );
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(VerifyResetPasswordOtpRequested(
      email: email,
      otpCode: otpCode,
    ));
  }

  /// Handle OTP resend for registration
  void handleResendRegisterOtp(BuildContext context, String email) {
    if (!canResend) return;
    
    final authBloc = context.read<AuthBloc>();
    authBloc.add(ResendRegisterOtpRequested(email: email));
    
    // Restart timer after resend
    startResendTimer();
  }

  /// Handle OTP resend for password reset
  void handleResendResetPasswordOtp(BuildContext context) {
    if (!canResend) return;
    
    // TODO: Implement resend reset password OTP API call
    startResendTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP code has been resent to your email'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  /// Navigate to login screen
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  /// Navigate to reset password screen
  void navigateToResetPassword(BuildContext context, String resetToken) {
    Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
      arguments: resetToken,
    );
  }

  /// Clear OTP form
  void clearOtp() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    for (var node in otpFocusNodes) {
      node.unfocus();
    }
  }

  /// Focus first OTP field
  void focusFirstField() {
    otpFocusNodes[0].requestFocus();
  }

  /// Clear OTP and focus first field
  void clearOtpAndFocusFirstField() {
    clearOtp();
    // Use a small delay to ensure the clear operation completes before focusing
    Future.delayed(const Duration(milliseconds: 100), () {
      focusFirstField();
    });
  }

  /// Dispose resources
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    cancelResendTimer();
  }
}
