import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/activity_data_entity.dart';

class AddActivitiesModal extends StatelessWidget {
  final List<ActivityDataEntity> activities;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const AddActivitiesModal({
    Key? key,
    required this.activities,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.responsiveIconSize(verySmall: 320, small: 360, large: 400),
          maxHeight: context.responsiveHeightPercentage(verySmall: 0.8, small: 0.85, large: 0.9),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: context.responsiveElevation(verySmall: 16, small: 18, large: 20),
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: context.responsiveElevation(verySmall: 32, small: 36, large: 40),
              spreadRadius: 0,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: context.responsivePadding(all: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green,
                    Colors.green.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
                  topRight: Radius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
                ),
              ),
              child: Column(
                children: [
                  // Icon with background
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.add_task_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Thêm hoạt động',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Xác nhận thêm ${activities.length} hoạt động vào lịch trình',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bạn có muốn thêm ${activities.length} hoạt động vào lịch trình không?',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Activities preview
                    Text(
                      'Danh sách hoạt động:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activities list
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey[200]!,
                          ),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activities.length > 5 ? 5 : activities.length,
                          itemBuilder: (context, index) {
                            final activity = activities[index];
                            return _buildActivityItem(activity, index + 1);
                          },
                        ),
                      ),
                    ),

                    if (activities.length > 5) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.more_horiz_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Và ${activities.length - 5} hoạt động khác...',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: onConfirm,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text('Thêm ${activities.length} hoạt động'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityDataEntity activity, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Index number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Activity info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.placeName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        activity.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(activity.checkInTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
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
