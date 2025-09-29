import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Controller for login functionality
/// Handles login form state and validation
class LoginController {
  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form state
  bool isPasswordVisible = false;
  bool rememberMe = false;

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  /// Toggle remember me checkbox
  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
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

  /// Validate password field
  String? validatePassword(String? value) {
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

  /// Handle login form submission
  void handleLogin(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      LoginRequested(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  /// Navigate to register screen
  void navigateToRegister(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  /// Clear form data
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    isPasswordVisible = false;
    rememberMe = false;
  }

  /// Dispose resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
