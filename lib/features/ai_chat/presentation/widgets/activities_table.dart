import 'package:flutter/material.dart';
import '../../domain/entities/activity_data_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class ActivitiesTable extends StatelessWidget {
  final List<ActivityDataEntity> activities;

  const ActivitiesTable({
    Key? key,
    required this.activities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group activities by date
    final groupedActivities = _groupActivitiesByDate(activities);

    return Container(
      margin: context.responsiveMargin(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: context.responsiveElevation(verySmall: 3, small: 3.5, large: 4),
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: context.responsivePadding(all: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                topRight: Radius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
                ),
                SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...groupedActivities.entries.map((entry) {
            final date = entry.key;
            final dayActivities = entry.value;
            return _buildDaySchedule(context, date, dayActivities);
          }).toList(),
        ],
      ),
    );
  }

  Map<String, List<ActivityDataEntity>> _groupActivitiesByDate(List<ActivityDataEntity> activities) {
    final Map<String, List<ActivityDataEntity>> grouped = {};
    
    for (final activity in activities) {
      final date = _extractDate(activity.checkInTime);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(activity);
    }
    
    // Sort activities within each day by check-in time
    grouped.forEach((date, activities) {
      activities.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
    });
    
    return grouped;
  }

  String _extractDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Ngày không xác định';
    }
  }

  Widget _buildDaySchedule(BuildContext context, String date, List<ActivityDataEntity> activities) {
    return Container(
      margin: context.responsiveMargin(all: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: context.responsivePadding(all: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
                topRight: Radius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: context.responsiveIconSize(verySmall: 14, small: 15, large: 16),
                ),
                SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                Text(
                  'Ngày $date',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Activities table with better layout
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: context.screenWidth - context.responsiveSpacing(verySmall: 24, small: 28, large: 32),
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                border: TableBorder.all(color: Colors.grey[200]!),
                columnSpacing: context.responsiveSpacing(verySmall: 12, small: 14, large: 16),
                horizontalMargin: context.responsiveSpacing(verySmall: 8, small: 10, large: 12),
                columns: [
                  DataColumn(
                    label: Container(
                      width: context.responsiveIconSize(verySmall: 80, small: 90, large: 100),
                      child: Text(
                        'Thời gian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: context.responsiveIconSize(verySmall: 160, small: 180, large: 200),
                      child: Text(
                        'Hoạt động',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: context.responsiveIconSize(verySmall: 160, small: 180, large: 200),
                      child: Text(
                        'Địa điểm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
                rows: activities.map((activity) => DataRow(
                  cells: [
                    DataCell(
                      Container(
                        width: context.responsiveIconSize(verySmall: 80, small: 90, large: 100),
                        child: Text(
                          '${_formatTime(activity.checkInTime)}\n${_formatTime(activity.checkOutTime)}',
                          style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: context.responsiveIconSize(verySmall: 160, small: 180, large: 200),
                        child: Text(
                          activity.placeName,
                          style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: context.responsiveIconSize(verySmall: 160, small: 180, large: 200),
                        child: Text(
                          activity.location,
                          style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12)),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _formatTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeString;
    }
  }
}
