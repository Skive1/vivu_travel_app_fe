import 'package:flutter/material.dart';
import '../../domain/entities/schedule_data_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class ScheduleCard extends StatelessWidget {
  final ScheduleDataEntity scheduleData;

  const ScheduleCard({
    Key? key,
    required this.scheduleData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: context.responsiveMargin(vertical: 8, horizontal: 16),
      padding: context.responsivePadding(all: 16),
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
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppColors.primary,
                size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
              ),
              SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
              Expanded(
                child: Text(
                  scheduleData.title,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
          _buildInfoRow(
            Icons.location_on,
            'Điểm xuất phát',
            scheduleData.startLocation,
            context,
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          _buildInfoRow(
            Icons.place,
            'Điểm đến',
            scheduleData.destination,
            context,
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          _buildInfoRow(
            Icons.date_range,
            'Thời gian',
            '${_formatDate(scheduleData.startDate)} - ${_formatDate(scheduleData.endDate)}',
            context,
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          _buildInfoRow(
            Icons.people,
            'Số người',
            '${scheduleData.participantsCount} người',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: context.responsiveIconSize(verySmall: 14, small: 15, large: 16),
          color: Colors.grey[600],
        ),
        SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(fontWeight: FontWeight.w500),
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
