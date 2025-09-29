import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'schedule_item.dart';

class ScheduleList extends StatelessWidget {
  final DateTime selectedDate;
  
  const ScheduleList({
    super.key,
    required this.selectedDate,
  });

  // Mock data for demonstration
  List<Map<String, dynamic>> get _mockSchedules {
    final now = DateTime.now();
    final today = _formatDate(now);
    final tomorrow = _formatDate(now.add(const Duration(days: 1)));
    final yesterday = _formatDate(now.subtract(const Duration(days: 1)));
    
    return [
      {
        'id': '1',
        'title': 'Tham quan Hạ Long',
        'location': 'Vịnh Hạ Long, Quảng Ninh',
        'time': '08:00 - 17:00',
        'date': today,
        'type': 'tour',
        'status': 'upcoming',
        'participants': 4,
        'price': 1200000,
      },
      {
        'id': '2',
        'title': 'Ăn tối tại nhà hàng',
        'location': 'Nhà hàng Sài Gòn, Q1',
        'time': '19:00 - 21:00',
        'date': today,
        'type': 'dining',
        'status': 'upcoming',
        'participants': 2,
        'price': 500000,
      },
      {
        'id': '3',
        'title': 'Check-in khách sạn',
        'location': 'Hotel Saigon, Q1',
        'time': '14:00 - 15:00',
        'date': tomorrow,
        'type': 'accommodation',
        'status': 'upcoming',
        'participants': 2,
        'price': 800000,
      },
      {
        'id': '4',
        'title': 'Tham quan Chợ Bến Thành',
        'location': 'Chợ Bến Thành, Q1',
        'time': '09:00 - 12:00',
        'date': tomorrow,
        'type': 'shopping',
        'status': 'upcoming',
        'participants': 2,
        'price': 0,
      },
      {
        'id': '5',
        'title': 'Bay về Hà Nội',
        'location': 'Sân bay Tân Sơn Nhất',
        'time': '16:00 - 18:00',
        'date': tomorrow,
        'type': 'transport',
        'status': 'upcoming',
        'participants': 2,
        'price': 1200000,
      },
      {
        'id': '6',
        'title': 'Tham quan Bảo tàng',
        'location': 'Bảo tàng Lịch sử Việt Nam',
        'time': '10:00 - 12:00',
        'date': yesterday,
        'type': 'tour',
        'status': 'completed',
        'participants': 2,
        'price': 100000,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Filter schedules for selected date
    final selectedDateStr = _formatDate(selectedDate);
    final filteredSchedules = _mockSchedules.where((schedule) => 
        schedule['date'] == selectedDateStr).toList();
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getHeaderText(selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (filteredSchedules.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Show all schedules
                    },
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Schedule list
          Expanded(
            child: filteredSchedules.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: filteredSchedules.length,
                    itemBuilder: (context, index) {
                      final schedule = filteredSchedules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScheduleItem(
                          id: schedule['id'],
                          title: schedule['title'],
                          location: schedule['location'],
                          time: schedule['time'],
                          date: schedule['date'],
                          type: schedule['type'],
                          status: schedule['status'],
                          participants: schedule['participants'],
                          price: schedule['price'],
                          onTap: () {
                            // Navigate to schedule details
                            _showScheduleDetails(context, schedule);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getHeaderText(DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selected == today) {
      return 'Lịch trình hôm nay';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Lịch trình ngày mai';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Lịch trình hôm qua';
    } else {
      return 'Lịch trình ${selectedDate.day}/${selectedDate.month}';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có lịch trình nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm lịch trình mới cho ngày này',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDetails(BuildContext context, Map<String, dynamic> schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Schedule details
              Text(
                schedule['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildDetailRow(Icons.location_on, schedule['location']),
              _buildDetailRow(Icons.access_time, schedule['time']),
              _buildDetailRow(Icons.calendar_today, schedule['date']),
              _buildDetailRow(Icons.people, '${schedule['participants']} người'),
              
              if (schedule['price'] > 0) ...[
                const SizedBox(height: 8),
                _buildDetailRow(Icons.attach_money, '${schedule['price']} VNĐ'),
              ],
              
              const Spacer(),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Chỉnh sửa',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
