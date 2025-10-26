import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordForm extends StatefulWidget {
  final ChangePasswordController controller;

  const ChangePasswordForm({
    super.key,
    required this.controller,
  });

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  @override
  void initState() {
    super.initState();
    // Set callback for UI updates
    widget.controller.setOnFormChanged(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.controller.formKey,
      child: Column(
        children: [
          // Current Password Field
          AuthTextField(
            controller: widget.controller.oldPasswordController,
            label: 'Current Password',
            placeholder: 'Enter your current password',
            obscureText: !widget.controller.isOldPasswordVisible,
            validator: widget.controller.validateOldPassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.controller.isOldPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.controller.toggleOldPasswordVisibility,
            ),
          ),

          SizedBox(height: context.responsiveSpacing(
            verySmall: 16.0,
            small: 20.0,
            large: 24.0,
          )),

          // New Password Field
          AuthTextField(
            controller: widget.controller.newPasswordController,
            label: 'New Password',
            placeholder: 'Enter your new password',
            obscureText: !widget.controller.isNewPasswordVisible,
            validator: widget.controller.validateNewPassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.controller.isNewPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.controller.toggleNewPasswordVisibility,
            ),
          ),

          SizedBox(height: context.responsiveSpacing(
            verySmall: 16.0,
            small: 20.0,
            large: 24.0,
          )),

          // Confirm Password Field
          AuthTextField(
            controller: widget.controller.confirmPasswordController,
            label: 'Confirm New Password',
            placeholder: 'Confirm your new password',
            obscureText: !widget.controller.isConfirmPasswordVisible,
            validator: widget.controller.validateConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                widget.controller.isConfirmPasswordVisible
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: widget.controller.toggleConfirmPasswordVisibility,
            ),
          ),

          SizedBox(height: context.responsiveSpacing(
            verySmall: 24.0,
            small: 32.0,
            large: 40.0,
          )),

          // Change Password Button
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: AuthButton(
                  text: 'Change Password',
                  isLoading: state is AuthLoading,
                  onPressed: () => widget.controller.handleChangePassword(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
