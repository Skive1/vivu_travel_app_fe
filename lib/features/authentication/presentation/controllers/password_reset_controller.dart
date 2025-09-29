import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Controller for password reset functionality
/// Handles forgot password and reset password forms
class PasswordResetController {
  // Forgot Password form controllers
  final GlobalKey<FormState> forgotPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController forgotPasswordEmailController = TextEditingController();

  // Reset Password form controllers
  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController = TextEditingController();

  // Reset Password form state
  bool isNewPasswordVisible = false;
  bool isConfirmNewPasswordVisible = false;

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
  }

  /// Toggle confirm new password visibility
  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible = !isConfirmNewPasswordVisible;
  }

  /// Validate email field
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.emailRequired;
    }
    
    if (value.length > InputConstraints.maxEmailLength) {
      return ValidationMessages.emailTooLong;
    }
    
    if (!RegExp(ValidationConstants.emailPattern).hasMatch(value)) {
      return ValidationMessages.emailInvalid;
    }
    
    return null;
  }

  /// Validate new password field
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.passwordRequired;
    }
    
    if (value.length < ValidationConstants.minPasswordLength) {
      return ValidationMessages.passwordTooShort;
    }
    
    if (value.length > InputConstraints.maxPasswordLength) {
      return ValidationMessages.passwordTooLong;
    }
    
    if (!RegExp(ValidationConstants.passwordPattern).hasMatch(value)) {
      return ValidationMessages.passwordWeak;
    }
    
    return null;
  }

  /// Validate confirm new password field
  String? validateConfirmNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.passwordRequired;
    }
    
    if (value != newPasswordController.text) {
      return ValidationMessages.passwordMismatch;
    }
    
    return null;
  }

  /// Handle forgot password form submission
  void handleForgotPassword(BuildContext context) {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      RequestPasswordResetRequested(
        email: forgotPasswordEmailController.text.trim(),
      ),
    );
  }

  /// Handle reset password form submission
  void handleResetPassword(BuildContext context, String resetToken) {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      ResetPasswordRequested(
        resetToken: resetToken,
        newPassword: newPasswordController.text,
      ),
    );
  }

  /// Show check email dialog
  void showCheckEmailDialog(BuildContext context, String email) {
    DialogUtils.showCustomDialog(
      context: context,
      dialog: CheckEmailDialog(
        email: email,
        onPressed: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pushNamed(
            AppRoutes.otpVerificationResetPassword,
            arguments: {'email': email, 'type': 'reset_password'},
          );
        },
      ),
    );
  }

  /// Navigate to login screen
  void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  /// Navigate to OTP verification screen
  void navigateToOtpVerification(BuildContext context, String email) {
    Navigator.of(context).pushNamed(
      AppRoutes.otpVerificationResetPassword,
      arguments: {'email': email, 'type': 'reset_password'},
    );
  }

  /// Clear forgot password form
  void clearForgotPasswordForm() {
    forgotPasswordEmailController.clear();
  }

  /// Clear reset password form
  void clearResetPasswordForm() {
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    isNewPasswordVisible = false;
    isConfirmNewPasswordVisible = false;
  }

  /// Clear all forms
  void clearAllForms() {
    clearForgotPasswordForm();
    clearResetPasswordForm();
  }

  /// Dispose resources
  void dispose() {
    forgotPasswordEmailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
  }
}

/// Custom dialog for check email confirmation
class CheckEmailDialog extends StatelessWidget {
  final String email;
  final VoidCallback onPressed;

  const CheckEmailDialog({
    super.key,
    required this.email,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Check your email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We have send password recovery\ninstruction to your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24BAEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
