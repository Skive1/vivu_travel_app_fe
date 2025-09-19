import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../injection_container.dart' as di;
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
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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

    return BlocProvider(
      create: (context) => di.sl<AuthBloc>(),
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.home);
            } else if (state is AuthError) {
              DialogUtils.showErrorDialog(
                context: context,
                title: 'Login Failed',
                message: state.message,
              );
            }
          },
          child: AuthContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),

                    // Header Section
                    const AuthHeader(
                      title: 'Sign In',
                      subtitle: 'Sign in to continue your journey',
                    ),

                    const SizedBox(height: 40),

                    // Email Field
                    AuthTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    AuthTextField(
                      controller: _passwordController,
                      label: 'Password',
                      isPassword: true,
                      isPasswordVisible: _isPasswordVisible,
                      onTogglePassword: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      validator: _validatePassword,
                    ),

                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password
                    LoginOptions(
                      rememberMe: _rememberMe,
                      onRememberMeChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),

                    const SizedBox(height: 32),

                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AuthButton(
                          isLoading: state is AuthLoading,
                          onPressed: () => _handleLogin(context),
                          text: 'Sign In',
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    const AuthDivider(),

                    const SizedBox(height: 24),

                    // Social Login Buttons
                    const SocialAuthSection(),

                    const SizedBox(height: 32),

                    // Sign Up Link
                    const SignUpLink(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    authBloc.add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
