import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Color(0xFFE0E0E0), // Colors.grey[300] equivalent
            thickness: 1,
          ),
        ),
        Padding(
          padding: context.responsivePadding(
            horizontal: context.responsive(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            ),
          ),
          child: Text(
            'OR',
            style: TextStyle(
              color: const Color(0xFF757575), // Colors.grey[600] equivalent
              fontSize: context.responsiveFontSize(
                verySmall: 12.0,
                small: 13.0,
                large: 14.0,
              ),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Color(0xFFE0E0E0), // Colors.grey[300] equivalent
            thickness: 1,
          ),
        ),
      ],
    );
  }
}