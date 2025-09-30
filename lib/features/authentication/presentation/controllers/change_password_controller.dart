import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/validation_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Controller for change password functionality
/// Handles form validation and password change logic
class ChangePasswordController {
  // Form controllers
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Password visibility toggles
  bool isOldPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Callback for UI updates
  VoidCallback? _onFormChanged;

  /// Set callback for UI updates
  void setOnFormChanged(VoidCallback? callback) {
    _onFormChanged = callback;
  }

  /// Toggle old password visibility
  void toggleOldPasswordVisibility() {
    isOldPasswordVisible = !isOldPasswordVisible;
    _onFormChanged?.call();
  }

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    _onFormChanged?.call();
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    _onFormChanged?.call();
  }

  /// Validate old password
  String? validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Current password is required';
    }
    return null;
  }

  /// Validate new password
  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'New password is required';
    }
    
    if (value.length < ValidationConstants.minPasswordLength) {
      return 'Password must be at least ${ValidationConstants.minPasswordLength} characters';
    }
    
    if (!RegExp(ValidationConstants.passwordPattern).hasMatch(value)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    
    if (value != newPasswordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Handle change password
  void handleChangePassword(BuildContext context) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    // Check if new password is different from old password
    if (oldPassword == newPassword) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Invalid Password',
        message: 'New password must be different from current password',
      );
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(ChangePasswordRequested(
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
  }

  /// Clear form
  void clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    
    // Reset password visibility states
    isOldPasswordVisible = false;
    isNewPasswordVisible = false;
    isConfirmPasswordVisible = false;
    
    // Notify UI to rebuild
    _onFormChanged?.call();
  }

  /// Dispose resources
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
  }
}
