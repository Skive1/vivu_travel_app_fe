import 'package:flutter/material.dart';
import 'package:vivu_travel/core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../routes.dart';

class SignUpLink extends StatelessWidget {
  const SignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              fontSize: context.responsiveFontSize(
                verySmall: 12.0,
                small: 13.0,
                large: 14.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.register);
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: context.responsiveFontSize(
                  verySmall: 12.0,
                  small: 13.0,
                  large: 14.0,
                ),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}