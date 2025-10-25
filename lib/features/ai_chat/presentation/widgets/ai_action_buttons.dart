import 'package:flutter/material.dart';
import '../../domain/entities/activity_data_entity.dart';
import '../../domain/entities/schedule_data_entity.dart';
import '../../../../core/constants/app_colors.dart';

class AIActionButtons extends StatelessWidget {
  final ScheduleDataEntity? scheduleData;
  final List<ActivityDataEntity>? activitiesData;
  final VoidCallback? onCreateSchedule;
  final VoidCallback? onAddActivities;

  const AIActionButtons({
    Key? key,
    this.scheduleData,
    this.activitiesData,
    this.onCreateSchedule,
    this.onAddActivities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (scheduleData == null && (activitiesData == null || activitiesData!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          if (scheduleData != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateSchedule,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Tạo lịch trình'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (activitiesData != null && activitiesData!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddActivities,
                icon: const Icon(Icons.add),
                label: Text('Thêm ${activitiesData!.length} hoạt động'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
