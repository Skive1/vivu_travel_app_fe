import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: Color(0xFF757575), // Colors.grey[600] equivalent
              fontSize: 14,
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