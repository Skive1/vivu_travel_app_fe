import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/validator.dart';
import '../../../../routes.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/auth_button.dart';

class AuthController {
  // ================== LOGIN FORM SECTION ==================
  
  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form state
  bool isPasswordVisible = false;
  bool rememberMe = false;

  // ================== REGISTER FORM SECTION ==================
  
  // Register form controllers
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();
  final TextEditingController registerPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Register form state
  bool isRegisterPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;
  String selectedGender = 'Nam';
  DateTime? selectedDate;

  // ================== FORGOT PASSWORD SECTION ==================
  
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

  // ================== OTP VERIFICATION SECTION ==================
  
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

  // ================== VALIDATION METHODS ==================

  String? validateEmail(String? value) => Validator.validateEmail(value);
  String? validatePassword(String? value) => Validator.validatePassword(value);
  String? validateName(String? value) => Validator.validateName(value);
  String? validatePhone(String? value) => Validator.validatePhone(value);
  String? validateConfirmPassword(String? value) => 
      Validator.validateConfirmPassword(value, registerPasswordController.text);
  String? validateConfirmNewPassword(String? value) => 
      Validator.validateConfirmPassword(value, newPasswordController.text);
  
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  // ================== FORM ACTION METHODS ==================

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
  }

  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible = !isRegisterPasswordVisible;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
  }

  void toggleConfirmNewPasswordVisibility() {
    isConfirmNewPasswordVisible = !isConfirmNewPasswordVisible;
  }

  void toggleAgreeTerms(bool? value) {
    agreeTerms = value ?? false;
  }

  void selectGender(String gender) {
    selectedGender = gender;
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF24BAEC),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
    }
  }

  String get formattedDate {
    if (selectedDate == null) return 'Select Date of Birth';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  // ================== BUSINESS ACTION METHODS ==================

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

  void handleRegister(BuildContext context) {
    if (!registerFormKey.currentState!.validate()) return;

    if (selectedDate == null) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Date Required',
        message: 'Please select your date of birth',
      );
      return;
    }

    if (!agreeTerms) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Terms Required',
        message: 'Please agree to the terms and conditions',
      );
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      RegisterRequested(
        email: registerEmailController.text.trim(),
        password: registerPasswordController.text,
        dateOfBirth: selectedDate!.toIso8601String(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        avatarUrl: '', // Default empty string
        gender: selectedGender,
      ),
    );
  }

  void handleForgotPassword(BuildContext context) {
    if (!forgotPasswordFormKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      RequestPasswordResetRequested(
        email: forgotPasswordEmailController.text.trim(),
      ),
    );
  }

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

  // ================== OTP METHODS ==================

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

  void cancelResendTimer() {
    _resendTimer?.cancel();
  }

  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  bool isOtpComplete() {
    return getOtpCode().length == 6;
  }

  void handleOtpChange(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
  }

  void handleBackspace(int index) {
    if (index > 0 && otpControllers[index].text.isEmpty) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void handleVerifyOtp(BuildContext context, String email) {
    final otpCode = getOtpCode();
    final validationError = Validator.validateOtp(otpCode);
    
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

  void handleVerifyResetPasswordOtp(BuildContext context, String email) {
    final otpCode = getOtpCode();
    
    if (otpCode.length != 6) {
      DialogUtils.showErrorDialog(
        context: context,
        title: 'Invalid OTP',
        message: 'Please enter complete 6-digit OTP code',
      );
      return;
    }

    final authBloc = context.read<AuthBloc>();
    authBloc.add(VerifyResetPasswordOtpRequested(
      email: email,
      otpCode: otpCode,
    ));
  }

  void handleResendOtp(BuildContext context, String email) {
    if (!canResend) return;
    
    final authBloc = context.read<AuthBloc>();
    authBloc.add(ResendRegisterOtpRequested(email: email));
  }

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

  void navigateToResetPassword(BuildContext context, String resetToken) {
    Navigator.of(context).pushNamed(
      AppRoutes.resetPassword,
      arguments: resetToken,
    );
  }

  // ================== LOGOUT SECTION ==================

  Future<void> handleLogout(BuildContext context) async {
    final confirmed = await _showLogoutConfirmation(context);
    
    if (confirmed == true && context.mounted) {
      _triggerLogout(context);
    }
  }

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

  void _triggerLogout(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(LogoutRequested());
  }

  void handleDirectLogout(BuildContext context) {
    if (context.mounted) {
      _triggerLogout(context);
    }
  }

  // ================== CLEANUP ==================

  void dispose() {
    // Login controllers
    emailController.dispose();
    passwordController.dispose();
    
    // Register controllers
    nameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();

    // Forgot password controllers
    forgotPasswordEmailController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();

    // OTP controllers and timers
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    cancelResendTimer();
  }
}

// ================== CUSTOM DIALOG WIDGET ==================

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
              child: AuthButton(
                text: 'OK',
                isLoading: false,
                onPressed: onPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
