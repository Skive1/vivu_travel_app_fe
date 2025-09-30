import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/login_options.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_auth_section.dart';
import '../widgets/sign_up_link.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final LoginController _loginController;

  @override
  void initState() {
    super.initState();
    _loginController = LoginController();
  }

  @override
  void dispose() {
    _loginController.dispose();
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

    return Scaffold(
        // Ensure full screen coverage
        body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.of(context).pushReplacementNamed(AppRoutes.home);
              } else if (state is AuthError) {
                DialogUtils.showErrorDialog(
                  context: context,
                  title: state.title ?? 'Login Failed',
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
                            key: _loginController.formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Dynamic top spacing based on screen height
                                SizedBox(height: screenSize.height * 0.12),

                                // Header Section
                                const AuthHeader(
                                  title: 'Sign In',
                                  subtitle: 'Sign in to continue your journey',
                                ),

                                SizedBox(height: screenSize.height * 0.05),

                                // Email Field
                                AuthTextField(
                                  controller: _loginController.emailController,
                                  label: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _loginController.validateEmail,
                                ),

                                const SizedBox(height: 16),

                                // Password Field
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return AuthTextField(
                                      controller: _loginController.passwordController,
                                      label: 'Password',
                                      isPassword: true,
                                      isPasswordVisible: _loginController.isPasswordVisible,
                                      onTogglePassword: () {
                                        setState(() {
                                          _loginController.togglePasswordVisibility();
                                        });
                                      },
                                
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                // Remember Me & Forgot Password
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    return LoginOptions(
                                      rememberMe: _loginController.rememberMe,
                                      onRememberMeChanged: (value) {
                                        setState(() {
                                          _loginController.toggleRememberMe(value);
                                        });
                                      },
                                    );
                                  },
                                ),

                                SizedBox(height: screenSize.height * 0.04),

                                // Login Button
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return SizedBox(
                                      width: double.infinity,
                                      child: AuthButton(
                                        isLoading: state is AuthLoading,
                                        onPressed: () => _loginController.handleLogin(context),
                                        text: 'Sign In',
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

                                // Sign Up Link
                                const SignUpLink(),

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
      );
  }
}
