import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../routes.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/auth_screen_layout.dart';
import '../widgets/reset_password_form.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/password_reset_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;
  
  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late final PasswordResetController _authController;

  @override
  void initState() {
    super.initState();
    _authController = PasswordResetController();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordResetSuccess) {
          DialogUtils.showSuccessDialog(
            context: context,
            title: 'Success',
            message: state.message,
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => false,
              );
            },
          );
        } else if (state is AuthError) {
          DialogUtils.showErrorDialog(
            context: context,
            title: 'Error',
            message: state.message,
          );
        }
      },
      child: AuthScreenLayout(
        title: 'Reset Password',
        subtitle: 'Enter your new password below',
        child: ResetPasswordForm(
          controller: _authController,
          resetToken: widget.resetToken,
        ),
      ),
    );
  }
}