import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/user_storage.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../bloc/schedule_event.dart';
import 'schedule_calendar.dart';
import 'schedule_list.dart';
import '../bloc/schedule_bloc.dart';

class ScheduleContent extends StatefulWidget {
  final String? scheduleId;

  const ScheduleContent({super.key, this.scheduleId});

  @override
  State<ScheduleContent> createState() => _ScheduleContentState();
}

class _ScheduleContentState extends State<ScheduleContent> {
  int _currentIndex = 2; // Schedule tab is index 2
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.scheduleId != null) {
      context.read<ScheduleBloc>().add(
        GetActivitiesByScheduleEvent(scheduleId: widget.scheduleId!),
      );
    }
  }

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
        // Navigate to schedule list screen
        _navigateToScheduleList();
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

  void _navigateToScheduleList() async {
    try {
      final user = await UserStorage.getUserProfile();
      if (user != null && user.id.isNotEmpty) {
        Navigator.pushNamed(
          context, 
          '/schedule-list',
          arguments: user.id,
        );
        // Reset currentIndex after navigation
        setState(() {
          _currentIndex = 0;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để xem lịch trình'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lấy thông tin người dùng'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  child: ScheduleList(
                    selectedDate: _selectedDate,
                    scheduleId: widget.scheduleId,
                  ),
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
