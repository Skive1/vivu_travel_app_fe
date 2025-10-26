import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/password_reset_controller.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final PasswordResetController _passwordResetController;

  @override
  void initState() {
    super.initState();
    _passwordResetController = PasswordResetController();
  }

  @override
  void dispose() {
    _passwordResetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PasswordResetRequestSuccess) {
              _passwordResetController.showCheckEmailDialog(context, state.email);
            } else if (state is AuthError) {
              DialogUtils.showErrorDialog(
                context: context,
                title: 'Error',
                message: state.message,
              );
            }
          },
          child: AuthContainer(
            child: SafeArea(
              child: Padding(
                padding: context.responsivePadding(
                  horizontal: context.responsive(
                    verySmall: 16.0,
                    small: 20.0,
                    large: 24.0,
                  ),
                  bottom: keyboardHeight + context.responsiveSpacing(
                    verySmall: 24.0,
                    small: 32.0,
                    large: 40.0,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Top Section
                    Column(
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: context.responsive(
                                verySmall: 36.0,
                                small: 40.0,
                                large: 44.0,
                              ),
                              height: context.responsive(
                                verySmall: 36.0,
                                small: 40.0,
                                large: 44.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                  verySmall: 8.0,
                                  small: 10.0,
                                  large: 12.0,
                                )),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: const Color(0xFF1A1A1A),
                                size: context.responsiveIconSize(
                                  verySmall: 16.0,
                                  small: 18.0,
                                  large: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 16.0,
                          small: 20.0,
                          large: 24.0,
                        )),
                        
                        // Vivu Travel Logo
                        Container(
                          width: context.responsive(
                            verySmall: 120.0,
                            small: 180.0,
                            large: 240.0,
                          ),
                          height: context.responsive(
                            verySmall: 120.0,
                            small: 180.0,
                            large: 240.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                              verySmall: 30.0,
                              small: 40.0,
                              large: 120.0,
                            )),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                              verySmall: 30.0,
                              small: 40.0,
                              large: 120.0,
                            )),
                            child: Image.asset(
                              'assets/images/vivu_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 16.0,
                          small: 20.0,
                          large: 24.0,
                        )),
                        
                        // Header
                        Column(
                          children: [
                            Text(
                              'Forgot password',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 22.0,
                                  small: 25.0,
                                  large: 28.0,
                                ),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                            
                            SizedBox(height: context.responsiveSpacing(
                              verySmall: 8.0,
                              small: 10.0,
                              large: 12.0,
                            )),
                            
                            Text(
                              'Enter your email account to reset\nyour password',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 12.0,
                                  small: 13.0,
                                  large: 14.0,
                                ),
                                color: const Color(0xFF757575),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Form Section
                    Column(
                      children: [
                        // Form
                        Form(
                          key: _passwordResetController.forgotPasswordFormKey,
                          child: Column(
                            children: [
                              AuthTextField(
                                controller: _passwordResetController.forgotPasswordEmailController,
                                placeholder: 'vivutravel@gmail.com',
                                keyboardType: TextInputType.emailAddress,
                                validator: _passwordResetController.validateEmail,
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 20.0,
                          small: 24.0,
                          large: 28.0,
                        )),
                        
                        // Reset Password Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: AuthButton(
                                text: 'Reset Password',
                                isLoading: state is AuthLoading,
                                onPressed: () => _passwordResetController.handleForgotPassword(context),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}