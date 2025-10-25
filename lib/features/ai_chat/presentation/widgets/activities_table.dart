import 'package:flutter/material.dart';
import '../../domain/entities/activity_data_entity.dart';
import '../../../../core/constants/app_colors.dart';

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8), // Reduced horizontal margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    fontSize: 16,
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
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ngày $date',
                  style: TextStyle(
                    fontSize: 14,
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
                minWidth: MediaQuery.of(context).size.width - 32, // Full width minus margins
              ),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
                border: TableBorder.all(color: Colors.grey[200]!),
                columnSpacing: 16,
                horizontalMargin: 12,
                columns: [
                  DataColumn(
                    label: Container(
                      width: 100,
                      child: Text(
                        'Thời gian',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 200,
                      child: Text(
                        'Hoạt động',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Container(
                      width: 200,
                      child: Text(
                        'Địa điểm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                        width: 100,
                        child: Text(
                          '${_formatTime(activity.checkInTime)}\n${_formatTime(activity.checkOutTime)}',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 200,
                        child: Text(
                          activity.placeName,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 200,
                        child: Text(
                          activity.location,
                          style: const TextStyle(fontSize: 12),
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
