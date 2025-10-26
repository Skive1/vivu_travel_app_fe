import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../controllers/password_reset_controller.dart';

class ForgotPasswordForm extends StatelessWidget {
  final PasswordResetController controller;

  const ForgotPasswordForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {

    return Form(
      key: controller.forgotPasswordFormKey,
      child: Column(
        children: [
          AuthTextField(
            controller: controller.forgotPasswordEmailController,
            placeholder: 'www.uihut@gmail.com',
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
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
                  onPressed: () => controller.handleForgotPassword(context),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
