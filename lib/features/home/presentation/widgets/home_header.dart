import 'package:flutter/material.dart';
import 'user_avatar.dart';
import 'notification_bell.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
          ),
        ),
        child: const Row(
          children: [
            Expanded(child: UserAvatar()),
            NotificationBell(),
          ],
        ),
      ),
    );
  }
}
