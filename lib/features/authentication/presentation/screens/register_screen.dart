import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_auth_section.dart';
import '../widgets/login_link.dart';
import '../widgets/terms_checkbox.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  @override
  Widget build(BuildContext context) {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Get screen dimensions
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
                  arguments: _authController.registerEmailController.text.trim(),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: keyboardHeight + 40,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _authController.registerFormKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dynamic top spacing
                                SizedBox(height: screenSize.height * 0.08),

                                // Header Section
                                const AuthHeader(
                                  title: 'Create Account',
                                  subtitle: 'Sign up to start your journey',
                                  showBackButton: true,
                                ),

                                SizedBox(height: screenSize.height * 0.04),

                                // Name Field
                                AuthTextField(
                                  controller: _authController.nameController,
                                  label: 'Full Name',
                                  keyboardType: TextInputType.name,
                                  validator: _authController.validateName,
                                ),

                                const SizedBox(height: 16),

                                // Email Field
                                AuthTextField(
                                  controller: _authController.registerEmailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _authController.validateEmail,
                                ),

                                const SizedBox(height: 16),

                                // Phone Field
                                AuthTextField(
                                  controller: _authController.phoneController,
                                  label: 'Phone Number',
                                  keyboardType: TextInputType.phone,
                                  validator: _authController.validatePhone,
                                ),

                                const SizedBox(height: 16),

                                // Address Field
                                AuthTextField(
                                  controller: _authController.addressController,
                                  label: 'Address',
                                  keyboardType: TextInputType.streetAddress,
                                  validator: _authController.validateAddress,
                                ),

                                const SizedBox(height: 16),

                                // Date of Birth Field
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await _authController.selectDate(context);
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
                                              _authController.formattedDate,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: _authController.selectedDate == null 
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

                                const SizedBox(height: 16),

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
                                                  title: const Text('Nam'),
                                                  value: 'Nam',
                                                  groupValue: _authController.selectedGender,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _authController.selectGender(value!);
                                                    });
                                                  },
                                                  activeColor: const Color(0xFF24BAEC),
                                                  contentPadding: EdgeInsets.zero,
                                                  dense: true,
                                                ),
                                              ),
                                              Expanded(
                                                child: RadioListTile<String>(
                                                  title: const Text('Nữ'),
                                                  value: 'Nữ',
                                                  groupValue: _authController.selectedGender,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _authController.selectGender(value!);
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

                                const SizedBox(height: 16),

                                // Password Field
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return AuthTextField(
                                      controller: _authController.registerPasswordController,
                                      label: 'Password',
                                      isPassword: true,
                                      isPasswordVisible: _authController.isRegisterPasswordVisible,
                                      onTogglePassword: () {
                                        setState(() {
                                          _authController.toggleRegisterPasswordVisibility();
                                        });
                                      },
                                      validator: _authController.validatePassword,
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Confirm Password Field
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return AuthTextField(
                                      controller: _authController.confirmPasswordController,
                                      label: 'Confirm Password',
                                      isPassword: true,
                                      isPasswordVisible: _authController.isConfirmPasswordVisible,
                                      onTogglePassword: () {
                                        setState(() {
                                          _authController.toggleConfirmPasswordVisibility();
                                        });
                                      },
                                      validator: _authController.validateConfirmPassword,
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Terms and Conditions
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return TermsCheckbox(
                                      isChecked: _authController.agreeTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _authController.toggleAgreeTerms(value);
                                        });
                                      },
                                    );
                                  },
                                ),

                                SizedBox(height: screenSize.height * 0.04),

                                // Register Button
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: AuthButton(
                                        text: 'Create Account',
                                        isLoading: state is AuthLoading,
                                        onPressed: () => _authController.handleRegister(context),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 24),

                                // Divider
                                const AuthDivider(),

                                const SizedBox(height: 24),

                                // Social Login Buttons
                                const SocialAuthSection(),

                                SizedBox(height: screenSize.height * 0.04),

                                // Login Link
                                const LoginLink(),

                                // Extra bottom spacing
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
