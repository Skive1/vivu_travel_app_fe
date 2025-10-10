import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/schedule_entity.dart';

class ScheduleListItem extends StatefulWidget {
  final ScheduleEntity schedule;
  final VoidCallback onTap;
  final Function(String)? onScheduleViewTap;

  const ScheduleListItem({
    Key? key,
    required this.schedule,
    required this.onTap,
    this.onScheduleViewTap,
  }) : super(key: key);

  @override
  State<ScheduleListItem> createState() => _ScheduleListItemState();
}

class _ScheduleListItemState extends State<ScheduleListItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Cache formatted dates to avoid repeated formatting
  String? _cachedStartDate;
  String? _cachedEndDate;

  @override
  void initState() {
    super.initState();
    _cacheFormattedDates();
  }

  @override
  void didUpdateWidget(ScheduleListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if any schedule data has changed
    if (oldWidget.schedule.startDate != widget.schedule.startDate ||
        oldWidget.schedule.endDate != widget.schedule.endDate ||
        oldWidget.schedule.title != widget.schedule.title ||
        oldWidget.schedule.status != widget.schedule.status ||
        oldWidget.schedule.sharedCode != widget.schedule.sharedCode) {
      print('🔄 ScheduleListItem: Schedule data changed, updating cache');
      _cacheFormattedDates();
    }
  }

  void _cacheFormattedDates() {
    _cachedStartDate = _formatDate(widget.schedule.startDate);
    _cachedEndDate = _formatDate(widget.schedule.endDate);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                    widget.schedule.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(widget.schedule.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(widget.schedule.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(widget.schedule.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.schedule.startLocation} → ${widget.schedule.destination}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Date
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$_cachedStartDate - $_cachedEndDate',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Participants and Shared status
            Row(
              children: [
                const Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.schedule.participantsCount} người tham gia',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (widget.schedule.sharedCode != '') ...[
                  const Icon(
                    Icons.share,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Đã chia sẻ',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Riêng tư',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
            
            // Notes intentionally hidden on list item for a cleaner layout
            
            const SizedBox(height: 12),
            
            // View Schedule Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onScheduleViewTap?.call(widget.schedule.id);
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text('Xem lịch trình'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
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
      case 'pending':
        return 'Chờ bắt đầu';
      default:
        return status;
    }
  }
}