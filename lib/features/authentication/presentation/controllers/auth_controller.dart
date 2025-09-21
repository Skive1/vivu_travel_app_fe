import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class AuthController {
  // ================== LOGIN FORM SECTION ==================
  
  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Form state
  bool isPasswordVisible = false;
  bool rememberMe = false;

  // Validation methods (delegating to core Validator)
  String? validateEmail(String? value) => Validator.validateEmail(value);
  String? validatePassword(String? value) => Validator.validatePassword(value);

  // Form actions
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  void toggleRememberMe(bool? value) {
    rememberMe = value ?? false;
  }

  // Login business action
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

  // Register validation methods
  String? validateName(String? value) => Validator.validateName(value);
  String? validatePhone(String? value) => Validator.validatePhone(value);
  String? validateConfirmPassword(String? value) => 
      Validator.validateConfirmPassword(value, registerPasswordController.text);
  
  String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  // Register form actions
  void toggleRegisterPasswordVisibility() {
    isRegisterPasswordVisible = !isRegisterPasswordVisible;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
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

  // Register business action
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

  void handleResendOtp(BuildContext context) {
    if (!canResend) return;
    
    // TODO: Implement resend OTP API call
    startResendTimer();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('OTP code has been resent to your email'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // ================== LOGOUT SECTION ==================

  /// Xử lý logout với confirmation dialog
  Future<void> handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await _showLogoutConfirmation(context);
    
    if (confirmed == true && context.mounted) {
      // Trigger logout through AuthBloc
      _triggerLogout(context);
    }
  }

  /// Hiển thị dialog xác nhận logout
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

  /// Gửi logout event đến AuthBloc
  void _triggerLogout(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    authBloc.add(LogoutRequested());
  }

  /// Direct logout mà không cần confirmation (dùng cho auto logout)
  void handleDirectLogout(BuildContext context) {
    if (context.mounted) {
      _triggerLogout(context);
    }
  }

  // ================== CLEANUP ==================

  /// Cleanup resources
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
