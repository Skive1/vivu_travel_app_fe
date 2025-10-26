import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_input_field.dart';
import '../controllers/otp_controller.dart';
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
  late final OtpController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = OtpController();
    _otpController.startResendTimer(onUpdate: () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
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
              // Clear OTP input when verification fails
              _otpController.clearOtpAndFocusFirstField();
              
              DialogUtils.showErrorDialog(
                context: context,
                title: 'Verification Failed',
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
                            verySmall: 180.0,
                            small: 210.0,
                            large: 240.0,
                          ),
                          height: context.responsive(
                            verySmall: 180.0,
                            small: 210.0,
                            large: 240.0,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                              verySmall: 80.0,
                              small: 100.0,
                              large: 120.0,
                            )),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                              verySmall: 80.0,
                              small: 100.0,
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
                              'OTP Verification',
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
                              'Please check your email ${widget.email}\nto see the verification code',
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
                        // OTP Code Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'OTP Code',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 14.0,
                                small: 15.0,
                                large: 16.0,
                              ),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        )),
                        
                        // OTP Input Fields
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return OtpInputField(
                                  controller: _otpController.otpControllers[index],
                                  focusNode: _otpController.otpFocusNodes[index],
                                  onChanged: (value) {
                                    _otpController.handleOtpChange(value, index);
                                    if (_otpController.isOtpComplete()) {
                                      // Auto verify when OTP is complete
                                      _otpController.handleVerifyRegisterOtp(context, widget.email);
                                    }
                                    setState(() {}); // Rebuild to update button state
                                  },
                                  onBackspace: () => _otpController.handleBackspace(index),
                                );
                              }),
                            );
                          },
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 20.0,
                          small: 24.0,
                          large: 28.0,
                        )),
                        
                        // Verify Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: AuthButton(
                                text: 'Verify',
                                isLoading: state is AuthLoading,
                                onPressed: _otpController.isOtpComplete() 
                                    ? () => _otpController.handleVerifyRegisterOtp(context, widget.email)
                                    : () {},
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 12.0,
                          small: 14.0,
                          large: 16.0,
                        )),
                        
                        // Resend Code Section
                        StatefulBuilder(
                          builder: (context, setState) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Resend code to ',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(
                                      verySmall: 12.0,
                                      small: 13.0,
                                      large: 14.0,
                                    ),
                                    color: const Color(0xFF757575),
                                  ),
                                ),
                                if (_otpController.canResend)
                                  GestureDetector(
                                    onTap: () {
                                      _otpController.handleResendRegisterOtp(context, widget.email);
                                      setState(() {});
                                    },
                                    child: Text(
                                      'Resend',
                                      style: TextStyle(
                                        fontSize: context.responsiveFontSize(
                                          verySmall: 12.0,
                                          small: 13.0,
                                          large: 14.0,
                                        ),
                                        color: const Color(0xFF24BAEC),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    '${_otpController.resendCountdown.toString().padLeft(2, '0')}s',
                                    style: TextStyle(
                                      fontSize: context.responsiveFontSize(
                                        verySmall: 12.0,
                                        small: 13.0,
                                        large: 14.0,
                                      ),
                                      color: const Color(0xFF757575),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
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