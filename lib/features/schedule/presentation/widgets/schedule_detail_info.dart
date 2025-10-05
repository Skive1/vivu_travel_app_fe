import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleDetailInfo extends StatelessWidget {
  final ScheduleEntity schedule;

  const ScheduleDetailInfo({
    Key? key,
    required this.schedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            children: [
              Expanded(
                child: Text(
                  schedule.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(schedule.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusText(schedule.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(schedule.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Location
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Địa điểm',
            content: '${schedule.startLocation} → ${schedule.destination}',
          ),
          const SizedBox(height: 16),
          
          // Date range
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Thời gian',
            content: '${_formatDateTime(schedule.startDate)} - ${_formatDateTime(schedule.endDate)}',
          ),
          const SizedBox(height: 16),
          
          // Participants
          _buildInfoRow(
            icon: Icons.people_outline,
            title: 'Số người tham gia',
            content: '${schedule.participantsCount} người',
          ),
          const SizedBox(height: 16),
          
          // Shared status
          _buildInfoRow(
            icon: Icons.share_outlined,
            title: 'Trạng thái chia sẻ',
            content: schedule.sharedCode != null ? 'Đã chia sẻ' : 'Chưa chia sẻ',
            contentColor: schedule.sharedCode != null ? AppColors.primary : AppColors.textSecondary,
          ),
          
          // Notes (if available)
          if (schedule.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.note_outlined,
              title: 'Ghi chú',
              content: schedule.notes,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: contentColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang diễn ra';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
