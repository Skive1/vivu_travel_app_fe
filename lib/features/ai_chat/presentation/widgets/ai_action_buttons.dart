import 'package:flutter/material.dart';
import '../../domain/entities/activity_data_entity.dart';
import '../../domain/entities/schedule_data_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

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
      margin: context.responsiveMargin(vertical: 8, horizontal: 16),
      child: Column(
        children: [
          if (scheduleData != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateSchedule,
                icon: Icon(
                  Icons.calendar_today,
                  size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18),
                ),
                label: Text(
                  'Tạo lịch trình',
                  style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: context.responsivePadding(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
                  ),
                ),
              ),
            ),
            SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          ],
          if (activitiesData != null && activitiesData!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddActivities,
                icon: Icon(
                  Icons.add,
                  size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18),
                ),
                label: Text(
                  'Thêm ${activitiesData!.length} hoạt động',
                  style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15)),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: context.responsivePadding(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
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
