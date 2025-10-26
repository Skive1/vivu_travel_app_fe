import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: context.responsiveFontSize(
                  verySmall: 12.0,
                  small: 13.0,
                  large: 14.0,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: context.responsiveFontSize(
                verySmall: 12.0,
                small: 13.0,
                large: 14.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
