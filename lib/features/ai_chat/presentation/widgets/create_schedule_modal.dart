import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/schedule_data_entity.dart';

class CreateScheduleModal extends StatelessWidget {
  final ScheduleDataEntity scheduleData;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const CreateScheduleModal({
    Key? key,
    required this.scheduleData,
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
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
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
                    padding: context.responsivePadding(all: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 16, small: 18, large: 20)),
                    ),
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                  // Title
                  Text(
                    'Tạo lịch trình',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(verySmall: 20, small: 22, large: 24),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                  // Subtitle
                  Text(
                    'Xác nhận thông tin lịch trình mới',
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: context.responsivePadding(all: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question
                    Container(
                      padding: context.responsivePadding(all: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            color: AppColors.primary,
                            size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
                          ),
                          SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                          Expanded(
                            child: Text(
                              'Bạn có muốn tạo lịch trình "${scheduleData.title}" không?',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.responsiveSpacing(verySmall: 16, small: 18, large: 20)),

                    // Schedule details
                    Text(
                      'Thông tin lịch trình:',
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),

                    // Schedule info card
                    Container(
                      padding: context.responsivePadding(all: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withValues(alpha: 0.05),
                            AppColors.primary.withValues(alpha: 0.02),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 16, small: 18, large: 20)),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_on_rounded,
                          iconColor: Colors.red,
                          label: 'Điểm xuất phát',
                          value: scheduleData.startLocation,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.place_rounded,
                          iconColor: Colors.green,
                          label: 'Điểm đến',
                          value: scheduleData.destination,
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.date_range_rounded,
                          iconColor: Colors.orange,
                          label: 'Thời gian',
                          value: _formatDateRange(scheduleData.startDate, scheduleData.endDate),
                          context: context,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.people_rounded,
                          iconColor: Colors.blue,
                          label: 'Số người tham gia',
                          value: '${scheduleData.participantsCount} người',
                          context: context,
                        ),
                      ],
                    ),
                  ),

                    SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),

                    // Action buttons
                    ResponsiveUtils.isVerySmallPhone(context) 
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: onCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: context.responsivePadding(vertical: 16),
                                  side: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                  ),
                                ),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onConfirm,
                                icon: Icon(Icons.add_rounded, size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20)),
                                label: Text('Tạo lịch trình', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: context.responsivePadding(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                  ),
                                  elevation: 0,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onCancel,
                                style: OutlinedButton.styleFrom(
                                  padding: context.responsivePadding(vertical: 16),
                                  side: BorderSide(
                                    color: AppColors.border,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                  ),
                                ),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: onConfirm,
                                icon: Icon(Icons.add_rounded, size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20)),
                                label: Text('Tạo lịch trình', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: context.responsivePadding(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 12, small: 14, large: 16)),
                                  ),
                                  elevation: 0,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
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

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: context.responsivePadding(all: 8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 8, small: 9, large: 10)),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18),
          ),
        ),
        SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateRange(String startDate, String endDate) {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      
      final startFormatted = '${start.day}/${start.month}/${start.year}';
      final endFormatted = '${end.day}/${end.month}/${end.year}';
      
      return '$startFormatted - $endFormatted';
    } catch (e) {
      return '$startDate - $endDate';
    }
  }
}
