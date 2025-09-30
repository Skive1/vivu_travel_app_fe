import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/dialog_utils.dart';
import '../widgets/auth_screen_layout.dart';
import '../widgets/change_password_form.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final ChangePasswordController _changePasswordController;

  @override
  void initState() {
    super.initState();
    _changePasswordController = ChangePasswordController();
  }

  @override
  void dispose() {
    _changePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is ChangePasswordSuccess) {
          // Clear form inputs
          _changePasswordController.clearForm();
          
          DialogUtils.showSuccessDialog(
            context: context,
            title: 'Success',
            message: state.message,
            onPressed: () {
              // Navigate back to profile screen
              Navigator.of(context).pop();
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
        title: 'Change Password',
        subtitle: 'Enter your current password and new password',
        child: ChangePasswordForm(
          controller: _changePasswordController,
        ),
      ),
    );
  }
}
