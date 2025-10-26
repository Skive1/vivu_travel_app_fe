import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';

import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/password_reset_controller.dart';

class ResetPasswordForm extends StatefulWidget {
  final PasswordResetController controller;
  final String resetToken;

  const ResetPasswordForm({
    super.key,
    required this.controller,
    required this.resetToken,
  });

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  @override
  Widget build(BuildContext context) {

    return Form(
      key: widget.controller.resetPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: widget.controller.newPasswordController,
            label: 'New Password',
            placeholder: 'Enter new password',
            obscureText: !widget.controller.isNewPasswordVisible,
            validator: widget.controller.validateNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.controller.isNewPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF757575),
              ),
              onPressed: () {
                setState(() {
                  widget.controller.toggleNewPasswordVisibility();
                });
              },
            ),
          ),
          
          SizedBox(height: context.responsiveSpacing(
            verySmall: 16.0,
            small: 20.0,
            large: 24.0,
          )),
          
          AuthTextField(
            controller: widget.controller.confirmNewPasswordController,
            label: 'Confirm Password',
            placeholder: 'Confirm new password',
            obscureText: !widget.controller.isConfirmNewPasswordVisible,
            validator: widget.controller.validateConfirmNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.controller.isConfirmNewPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF757575),
              ),
              onPressed: () {
                setState(() {
                  widget.controller.toggleConfirmNewPasswordVisibility();
                });
              },
            ),
          ),
          
          SizedBox(height: context.responsiveSpacing(
            verySmall: 20.0,
            small: 24.0,
            large: 28.0,
          )),
          
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: AuthButton(
                  text: 'Reset Password',
                  isLoading: state is AuthLoading,
                  onPressed: () => widget.controller.handleResetPassword(context, widget.resetToken),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
