import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../bloc/ScheduleBloc.dart';
import '../bloc/ScheduleEvent.dart';
import '../bloc/ScheduleState.dart';
import '../widgets/schedule_list_item.dart';
import '../widgets/schedule_list_item_skeleton.dart';
import 'schedule_detail_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  final String participantId;

  const ScheduleListScreen({
    Key? key,
    required this.participantId,
  }) : super(key: key);

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  int _currentIndex = 2; // Schedule tab is index 2

  @override
  void initState() {
    super.initState();
    context.read<ScheduleBloc>().add(
      GetSchedulesByParticipantEvent(participantId: widget.participantId),
    );
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
        // Already on schedule list screen
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch trình của tôi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5, // Show 5 skeleton items
              itemBuilder: (context, index) {
                return const ScheduleListItemSkeleton();
              },
            );
          } else if (state is ScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ScheduleBloc>().add(
                        RefreshSchedulesEvent(participantId: widget.participantId),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (state is ScheduleLoaded) {
            if (state.schedules.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 64,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có lịch trình nào',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hãy tạo lịch trình đầu tiên của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ScheduleBloc>().add(
                  RefreshSchedulesEvent(participantId: widget.participantId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = state.schedules[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ScheduleListItem(
                      schedule: schedule,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleDetailScreen(
                              schedule: schedule,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
            ),
          ),
          
          // Bottom navigation
          HomeBottomNav(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
          ),
        ],
      ),
    );
  }
}
