import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/widgets/home_header.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import 'schedule_calendar.dart';
import 'schedule_list.dart';
import 'schedule_fab.dart';

class ScheduleContent extends StatefulWidget {
  const ScheduleContent({super.key});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _currentIndex = 2; // Schedule tab is index 2
  DateTime _selectedDate = DateTime.now();

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to explore screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khám phá - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 2:
        // Already on schedule screen
        break;
      case 3:
        // Navigate to chat screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nhắn tin - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with user info and notification bell
        const HomeHeader(),
        
        // Main content area
        Expanded(
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [
                // Calendar section
                ScheduleCalendar(
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                
                // Schedule list section
                Expanded(
                  child: ScheduleList(selectedDate: _selectedDate),
                ),
              ],
            ),
          ),
        ),
        
        // Bottom navigation
        HomeBottomNav(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTap,
        ),
      ],
    );
  }
}
