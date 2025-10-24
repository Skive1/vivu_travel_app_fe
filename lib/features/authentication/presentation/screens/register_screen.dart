import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/login_link.dart';
import '../widgets/terms_checkbox.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/multi_step_register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final MultiStepRegisterController _registerController;

  @override
  void initState() {
    super.initState();
    _registerController = MultiStepRegisterController();
  }

  @override
  void dispose() {
    _registerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Get screen dimensions and safe area
    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: Scaffold(
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is RegisterSuccess) {
                Navigator.of(context).pushNamed(
                  AppRoutes.otpVerification,
                  arguments: _registerController.emailController.text.trim(),
                );
              } else if (state is AuthError) {
                DialogUtils.showErrorDialog(
                  context: context,
                  title: 'Registration Failed',
                  message: state.message,
                );
              }
            },
            child: AuthContainer(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: context.responsivePadding(
                    horizontal: 16,
                    vertical: 0,
                    bottom: keyboardHeight + context.responsiveSpacing(
                      verySmall: 24,
                      small: 32,
                      large: 40,
                    ),
                  ),
                  child: Form(
                    key: _registerController.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Indicator with Steps
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStepIndicator(1, 'Basic Info', _registerController.currentStep >= 1),
                            Container(
                              height: 2,
                              width: MediaQuery.of(context).size.width * 0.3,
                              color: _registerController.currentStep > 1 
                                  ? const Color(0xFF24BAEC) 
                                  : Colors.grey[300],
                            ),
                            _buildStepIndicator(2, 'Details', _registerController.currentStep >= 2),
                          ],
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 16,
                          small: 20,
                          large: 24,
                        )),
                        
                        // Header
                        AuthHeader(
                          title: _registerController.currentStepTitle,
                          subtitle: _registerController.currentStepSubtitle,
                          showBackButton: _registerController.currentStep > 1,
                          onBackPressed: _registerController.currentStep > 1 
                              ? () => setState(() => _registerController.previousStep())
                              : null,
                        ),

                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 20,
                          small: 24,
                          large: 32,
                        )),

                        // Form Content based on current step
                        _buildStepContent(),

                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 20,
                          small: 24,
                          large: 32,
                        )),

                        // Navigation Buttons
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_registerController.currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name Field
        AuthTextField(
          controller: _registerController.nameController,
          label: 'Full Name',
          keyboardType: TextInputType.name,
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Email Field
        AuthTextField(
          controller: _registerController.emailController,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          validator: _registerController.validateEmail,
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Phone Field
        AuthTextField(
          controller: _registerController.phoneController,
          label: 'Phone Number',
          keyboardType: TextInputType.phone,
          validator: _registerController.validatePhone,
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Password Field
        StatefulBuilder(
          builder: (context, setState) {
            return AuthTextField(
              controller: _registerController.passwordController,
              label: 'Password',
              isPassword: true,
              isPasswordVisible: _registerController.isPasswordVisible,
              onTogglePassword: () {
                setState(() {
                  _registerController.togglePasswordVisibility();
                });
              },
              validator: _registerController.validatePassword,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Address Field
        AuthTextField(
          controller: _registerController.addressController,
          label: 'Address',
          keyboardType: TextInputType.streetAddress,
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Date of Birth Field
        StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTap: () async {
                await _registerController.selectDate(context);
                setState(() {}); // Rebuild to show selected date
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _registerController.formattedDate,
                      style: TextStyle(
                        fontSize: 16,
                        color: _registerController.selectedDate == null 
                            ? Colors.grey[600] 
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Gender Radio Buttons
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gender',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _registerController.selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _registerController.selectGender(value!);
                            });
                          },
                          activeColor: const Color(0xFF24BAEC),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: _registerController.selectedGender,
                          onChanged: (String? value) {
                            setState(() {
                              _registerController.selectGender(value!);
                            });
                          },
                          activeColor: const Color(0xFF24BAEC),
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Confirm Password Field
        StatefulBuilder(
          builder: (context, setState) {
            return AuthTextField(
              controller: _registerController.confirmPasswordController,
              label: 'Confirm Password',
              isPassword: true,
              isPasswordVisible: _registerController.isConfirmPasswordVisible,
              onTogglePassword: () {
                setState(() {
                  _registerController.toggleConfirmPasswordVisibility();
                });
              },
              validator: _registerController.validateConfirmPassword,
            );
          },
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 8,
          small: 12,
          large: 16,
        )),

        // Terms and Conditions
        StatefulBuilder(
          builder: (context, setState) {
            return TermsCheckbox(
              isChecked: _registerController.agreeTerms,
              onChanged: (value) {
                setState(() {
                  _registerController.toggleAgreeTerms(value);
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepIndicator(int stepNumber, String stepTitle, bool isActive) {
    return Column(
      children: [
        Container(
          width: context.responsive(
            verySmall: 32.0,
            small: 36.0,
            large: 40.0,
          ),
          height: context.responsive(
            verySmall: 32.0,
            small: 36.0,
            large: 40.0,
          ),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF24BAEC) : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow: isActive ? [
              BoxShadow(
                color: const Color(0xFF24BAEC).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontSize: context.responsiveFontSize(
                  verySmall: 14.0,
                  small: 16.0,
                  large: 18.0,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: context.responsiveSpacing(
          verySmall: 4,
          small: 6,
          large: 8,
        )),
        Text(
          stepTitle,
          style: TextStyle(
            color: isActive ? const Color(0xFF24BAEC) : Colors.grey[600],
            fontSize: context.responsiveFontSize(
              verySmall: 10.0,
              small: 11.0,
              large: 12.0,
            ),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        // Main Action Button
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              child: AuthButton(
                text: _registerController.currentStep < _registerController.totalSteps 
                    ? 'Continue' 
                    : 'Create Account',
                isLoading: state is AuthLoading,
                onPressed: () {
                  setState(() {
                    _registerController.handleStepNavigation(context);
                  });
                },
              ),
            );
          },
        ),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 16,
          small: 20,
          large: 24,
        )),

        // Divider
        const AuthDivider(),

        SizedBox(height: context.responsiveSpacing(
          verySmall: 16,
          small: 20,
          large: 24,
        )),

        // Login Link
        const LoginLink(),
      ],
    );
  }
}
