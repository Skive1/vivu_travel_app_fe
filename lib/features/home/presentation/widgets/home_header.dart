import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'user_avatar.dart';
import 'notification_bell.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Info Section
          const Expanded(
            child: UserAvatar(),
          ),
          
          // Notification Bell
          const NotificationBell(),
        ],
      ),
    );
  }
}