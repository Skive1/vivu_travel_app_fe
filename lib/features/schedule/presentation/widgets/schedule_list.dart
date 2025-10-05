import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/activity_entity.dart';
import 'activity_timeline_item.dart';
import 'optimized_skeleton.dart';
import 'add_activity_form.dart';

class ScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  final String? scheduleId;
  
  const ScheduleList({
    super.key,
    required this.selectedDate,
    this.scheduleId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        if (state is ActivitiesLoading) {
          return const ActivityListSkeleton(itemCount: 3);
        } else if (state is ActivitiesError) {
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
                    if (scheduleId != null) {
                      context.read<ScheduleBloc>().add(
                        RefreshActivitiesEvent(scheduleId: scheduleId!),
                      );
                    }
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
        } else if (state is ActivitiesLoaded) {
          final activities = _filterActivitiesByDate(state.activities, selectedDate);
          
          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyStateTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyStateMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (scheduleId != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: BlocProvider.value(
                              value: context.read<ScheduleBloc>(),
                              child: AddActivityForm(
                                scheduleId: scheduleId!,
                                initialDate: selectedDate,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm hoạt động'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                ],
              ),
            );
          }

          // Sort activities by orderIndex
          activities.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

          return RefreshIndicator(
            onRefresh: () async {
              if (scheduleId != null) {
                context.read<ScheduleBloc>().add(
                  RefreshActivitiesEvent(scheduleId: scheduleId!),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: activities.length + (scheduleId != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    final isAppendButton = scheduleId != null && index == activities.length;
                    if (isAppendButton) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    ),
                                    child: BlocProvider.value(
                                      value: context.read<ScheduleBloc>(),
                                      child: AddActivityForm(
                                        scheduleId: scheduleId!,
                                        initialDate: selectedDate,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: const Icon(Icons.add, size: 24),
                            ),
                          ),
                        ),
                      );
                    }

                    final activity = activities[index];
                    final isLast = index == activities.length - 1;
                    return ActivityTimelineItem(
                      activity: activity,
                      isLast: isLast,
                    );
                  },
                ),
                ],
              ),
            ),
          );
        }

        // If no scheduleId provided, show empty state
        if (scheduleId == null) {
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
                  'Chọn một lịch trình',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Để xem các hoạt động trong lịch trình',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (scheduleId != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: BlocProvider.value(
                            value: context.read<ScheduleBloc>(),
                            child: AddActivityForm(
                              scheduleId: scheduleId!,
                              initialDate: selectedDate,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hoạt động'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  List<ActivityEntity> _filterActivitiesByDate(List<ActivityEntity> activities, DateTime selectedDate) {
    return activities.where((activity) {
      final activityDate = DateTime(
        activity.checkInTime.year,
        activity.checkInTime.month,
        activity.checkInTime.day,
      );
      final selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );
      return activityDate.isAtSameMomentAs(selected);
    }).toList();
  }

  String _getEmptyStateTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selected.isAtSameMomentAs(today)) {
      return 'Hôm nay không có hoạt động';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Ngày mai không có hoạt động';
    } else if (selected.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Hôm qua không có hoạt động';
    } else {
      return 'Không có hoạt động';
    }
  }

  String _getEmptyStateMessage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selected.isAtSameMomentAs(today)) {
      return 'Hãy thêm hoạt động cho ngày hôm nay';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Hãy thêm hoạt động cho ngày mai';
    } else if (selected.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Hôm qua không có hoạt động nào được lên lịch';
    } else {
      return 'Hãy thêm hoạt động cho ngày này';
    }
  }
}