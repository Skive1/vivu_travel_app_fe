import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/dialog_utils.dart';
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
                      child: Column(
                        children: [
                          SizedBox(height: screenSize.height * 0.08),
                          
                          // Back Button
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF1A1A1A),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: screenSize.height * 0.04),
                          
                          // Header
                          Column(
                            children: [
                              const Text(
                                'Forgot password',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              const Text(
                                'Enter your email account to reset\nyour password',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF757575),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: screenSize.height * 0.06),
                          
                          // Form
                          Form(
                            key: _passwordResetController.forgotPasswordFormKey,
                            child: Column(
                              children: [
                                AuthTextField(
                                  controller: _passwordResetController.forgotPasswordEmailController,
                                  placeholder: 'www.uihut@gmail.com',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _passwordResetController.validateEmail,
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: screenSize.height * 0.06),
                          
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
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}