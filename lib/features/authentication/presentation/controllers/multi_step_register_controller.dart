import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/validation_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

/// Controller for multi-step registration functionality
/// Handles registration form state and validation across multiple steps
class MultiStepRegisterController {
  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Form state
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool agreeTerms = false;
  String selectedGender = 'Male';
  DateTime? selectedDate;
  
  // Step management
  int currentStep = 1;
  final int totalSteps = 2;

  /// Get current step title
  String get currentStepTitle {
    switch (currentStep) {
      case 1:
        return 'Basic Information';
      case 2:
        return 'Additional Details';
      default:
        return 'Registration';
    }
  }

  /// Get current step subtitle
  String get currentStepSubtitle {
    switch (currentStep) {
      case 1:
        return 'Enter your basic information to get started';
      case 2:
        return 'Complete your profile with additional details';
      default:
        return 'Create your account';
    }
  }

  /// Get progress percentage
  double get progressPercentage => currentStep / totalSteps;

  /// Check if can go to next step
  bool get canGoNext {
    switch (currentStep) {
      case 1:
        return nameController.text.isNotEmpty &&
               emailController.text.isNotEmpty &&
               phoneController.text.isNotEmpty &&
               passwordController.text.isNotEmpty;
      case 2:
        return addressController.text.isNotEmpty &&
               selectedDate != null &&
               confirmPasswordController.text.isNotEmpty &&
               agreeTerms;
      default:
        return false;
    }
  }

  /// Go to next step
  void nextStep() {
    if (currentStep < totalSteps) {
      currentStep++;
    }
  }

  /// Go to previous step
  void previousStep() {
    if (currentStep > 1) {
      currentStep--;
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
  }

  /// Toggle terms agreement
  void toggleAgreeTerms(bool? value) {
    agreeTerms = value ?? false;
  }

  /// Select gender
  void selectGender(String gender) {
    selectedGender = gender;
  }

  /// Select date of birth
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

  /// Get formatted date string
  String get formattedDate {
    if (selectedDate == null) return 'Select Date of Birth';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  /// Validate name field
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.nameRequired;
    }
    
    if (value.length < ValidationConstants.minNameLength) {
      return ValidationMessages.nameTooShort;
    }
    
    if (value.length > InputConstraints.maxNameLength) {
      return ValidationMessages.nameTooLong;
    }
    
    return null;
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

  /// Validate confirm password field
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.passwordRequired;
    }
    
    if (value != passwordController.text) {
      return ValidationMessages.passwordMismatch;
    }
    
    return null;
  }

  /// Validate phone field
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationMessages.phoneRequired;
    }
    
    if (value.length < ValidationConstants.minPhoneLength) {
      return ValidationMessages.phoneTooShort;
    }
    
    if (value.length > InputConstraints.maxPhoneLength) {
      return ValidationMessages.phoneTooLong;
    }
    
    if (!RegExp(ValidationConstants.phonePattern).hasMatch(value)) {
      return ValidationMessages.phoneInvalid;
    }
    
    return null;
  }

  /// Handle step navigation
  void handleStepNavigation(BuildContext context) {
    if (currentStep < totalSteps) {
      // Validate current step
      if (formKey.currentState!.validate()) {
        nextStep();
      }
    } else {
      // Final step - submit registration
      handleRegister(context);
    }
  }

  /// Handle registration form submission
  void handleRegister(BuildContext context) {
    if (!formKey.currentState!.validate()) return;

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
        email: emailController.text.trim(),
        password: passwordController.text,
        dateOfBirth: selectedDate!.toIso8601String(),
        name: nameController.text.trim(),
        address: addressController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        gender: selectedGender,
      ),
    );
  }

  /// Clear form data
  void clearForm() {
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    phoneController.clear();
    addressController.clear();
    isPasswordVisible = false;
    isConfirmPasswordVisible = false;
    agreeTerms = false;
    selectedGender = 'Male';
    selectedDate = null;
    currentStep = 1;
  }

  /// Dispose resources
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    addressController.dispose();
  }
}
