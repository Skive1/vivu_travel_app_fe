import 'package:flutter/material.dart';

import '../../../../routes.dart';
import '../../../../core/utils/user_storage.dart';
import 'home_header.dart';
import 'home_body.dart';
import 'home_bottom_nav.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        const HomeHeader(),
        
        // Body Section - Scrollable Content
        Expanded(
          child: HomeBody(
            onRefresh: () async {
              // Simulate refresh
              await Future.delayed(const Duration(seconds: 2));
            },
          ),
        ),
        
        // Bottom Navigation
        HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            _handleNavigation(index);
          },
        ),
      ],
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        // Explore
        _showSnackBar('Khám phá - Coming soon!');
        break;
      case 2:
        // Schedule - Navigate to ScheduleListScreen
        _navigateToScheduleList();
        break;
      case 3:
        // Messages
        _showSnackBar('Nhắn tin - Coming soon!');
        break;
      case 4:
        // Profile - Navigate to ProfileScreen
        Navigator.pushNamed(context, AppRoutes.profile);
        // Reset currentIndex after navigation
        setState(() {
          _currentIndex = 0;
        });
        break;
    }
  }

  void _navigateToScheduleList() async {
    try {
      final user = await UserStorage.getUserProfile();
      if (user != null && user.id.isNotEmpty) {
        Navigator.pushNamed(
          context, 
          AppRoutes.scheduleList,
          arguments: user.id,
        );
        // Reset currentIndex after navigation
        setState(() {
          _currentIndex = 0;
        });
      } else {
        _showSnackBar('Vui lòng đăng nhập để xem lịch trình');
      }
    } catch (e) {
      _showSnackBar('Không thể lấy thông tin người dùng');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}