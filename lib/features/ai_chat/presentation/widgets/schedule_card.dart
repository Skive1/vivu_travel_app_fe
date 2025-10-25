import 'package:flutter/material.dart';
import '../../domain/entities/schedule_data_entity.dart';
import '../../../../core/constants/app_colors.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleDataEntity scheduleData;

  const ScheduleCard({
    Key? key,
    required this.scheduleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scheduleData.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on,
            'Điểm xuất phát',
            scheduleData.startLocation,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.place,
            'Điểm đến',
            scheduleData.destination,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.date_range,
            'Thời gian',
            '${_formatDate(scheduleData.startDate)} - ${_formatDate(scheduleData.endDate)}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.people,
            'Số người',
            '${scheduleData.participantsCount} người',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
