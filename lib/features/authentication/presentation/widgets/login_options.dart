import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../routes.dart';

class LoginOptions extends StatelessWidget {
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMeChanged;
  
  const LoginOptions({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberMe,
              onChanged: onRememberMeChanged,
              activeColor: const Color(0xFF0296E4),
            ),
            const Text(
              'Remember me',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
          },
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
