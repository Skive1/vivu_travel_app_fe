import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import 'login_controller.dart';
import 'register_controller.dart';
import 'otp_controller.dart';
import 'password_reset_controller.dart';

/// Main authentication controller
/// Manages all authentication-related controllers and common functionality
class AuthController {
  // Sub-controllers
  final LoginController loginController = LoginController();
  final RegisterController registerController = RegisterController();
  final OtpController otpController = OtpController();
  final PasswordResetController passwordResetController = PasswordResetController();

  /// Handle logout with confirmation
  Future<void> handleLogout(BuildContext context) async {
    final confirmed = await _showLogoutConfirmation(context);
    
    if (confirmed == true && context.mounted) {
      _triggerLogout(context);
    }
  }

  /// Show logout confirmation dialog
  Future<bool?> _showLogoutConfirmation(BuildContext context) async {
    return await DialogUtils.showConfirmDialog(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmColor: AppColors.error,
    );
  }

  /// Trigger logout action
  void _triggerLogout(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(LogoutRequested());
  }

  /// Handle direct logout without confirmation
  void handleDirectLogout(BuildContext context) {
    if (context.mounted) {
      _triggerLogout(context);
    }
  }

  /// Clear all form data
  void clearAllForms() {
    loginController.clearForm();
    registerController.clearForm();
    otpController.clearOtp();
    passwordResetController.clearAllForms();
  }

  /// Dispose all resources
  void dispose() {
    loginController.dispose();
    registerController.dispose();
    otpController.dispose();
    passwordResetController.dispose();
  }
}
