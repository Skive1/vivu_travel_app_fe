import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_input_field.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/constants/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  
  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController();
    _authController.startResendTimer(onUpdate: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authController.dispose();
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
            if (state is OtpVerificationSuccess) {
              DialogUtils.showSuccessDialog(
                context: context,
                title: 'Registration Successful',
                message: state.message,
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.login,
                    (route) => false,
                  );
                },
              );
            } else if (state is ResendRegisterOtpSuccess) {
              // Show success message for resend
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is AuthError) {
              DialogUtils.showErrorDialog(
                context: context,
                title: 'Verification Failed',
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
                                'OTP Verification',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                'Please check your email ${widget.email}\nto see the verification code',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF757575),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: screenSize.height * 0.06),
                          
                          // OTP Code Label
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'OTP Code',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // OTP Input Fields
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  return OtpInputField(
                                    controller: _authController.otpControllers[index],
                                    focusNode: _authController.otpFocusNodes[index],
                                    onChanged: (value) {
                                      _authController.handleOtpChange(value, index);
                                      if (_authController.isOtpComplete()) {
                                        // Auto verify when OTP is complete
                                        _authController.handleVerifyOtp(context, widget.email);
                                      }
                                      setState(() {}); // Rebuild to update button state
                                    },
                                    onBackspace: () => _authController.handleBackspace(index),
                                  );
                                }),
                              );
                            },
                          ),
                          
                          SizedBox(height: screenSize.height * 0.06),
                          
                          // Verify Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: AuthButton(
                                  text: 'Verify',
                                  isLoading: state is AuthLoading,
                                  onPressed: _authController.isOtpComplete() 
                                      ? () => _authController.handleVerifyOtp(context, widget.email)
                                      : () {},
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Resend Code Section
                          StatefulBuilder(
                            builder: (context, setState) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Resend code to ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                  if (_authController.canResend)
                                    GestureDetector(
                                      onTap: () {
                                        _authController.handleResendOtp(context, widget.email);
                                        setState(() {});
                                      },
                                      child: const Text(
                                        'Resend',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF24BAEC),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      '${_authController.resendCountdown.toString().padLeft(2, '0')}s',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF757575),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
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