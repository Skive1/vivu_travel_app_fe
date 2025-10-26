// duplicate import removed
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import 'edit_activity_sheet.dart';
import '../screens/activity_navigation_screen.dart';
import '../screens/activity_media_gallery.dart';
import 'checkin_modal.dart';
import 'package:flutter/material.dart';
import '../../../../injection_container.dart' as di;

class ActivityTimelineItem extends StatelessWidget {
  final ActivityEntity activity;
  final bool isLast;
  final DateTime selectedDate;
  final bool canEdit;
  final bool canDelete;

  const ActivityTimelineItem({
    Key? key,
    required this.activity,
    required this.isLast,
    required this.selectedDate,
    this.canEdit = false,
    this.canDelete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final emoji = _guessEmoji(activity);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ActivityNavigationScreen(activity: activity),
        ));
      },
      onLongPress: () {
        _showCheckInOptionsModal(context);
      },
      child: Builder(
        builder: (context) {
          return Container(
            margin: EdgeInsets.only(bottom: context.responsiveSpacing(
              verySmall: 12,
              small: 14,
              large: 16,
            )),
            child: Stack(
              children: [
                // Timeline indicator and connector, positioned relative to card height
                Positioned(
                  top: context.responsive(verySmall: 1.5, small: 2, large: 2),
                  left: context.responsive(verySmall: 8, small: 9, large: 10),
                  child: Container(
                    width: context.responsiveIconSize(
                      verySmall: 10,
                      small: 11,
                      large: 12,
                    ),
                    height: context.responsiveIconSize(
                      verySmall: 10,
                      small: 11,
                      large: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25), 
                        blurRadius: context.responsive(verySmall: 4, small: 5, large: 6), 
                        offset: Offset(0, context.responsive(verySmall: 1.5, small: 2, large: 2))
                      )],
                    ),
                  ),
                ),
                if (!isLast)
                  Positioned(
                    left: context.responsive(verySmall: 13, small: 14, large: 15), // center of the dot
                    top: context.responsive(verySmall: 16, small: 18, large: 20),
                    bottom: 0,
                    child: _DashedLinePaint(color: AppColors.border),
                  ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: context.responsiveSpacing(
                      verySmall: 28,
                      small: 30,
                      large: 32,
                    )),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                            verySmall: 10,
                            small: 11,
                            large: 12,
                          )),
                          border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03), 
                            blurRadius: context.responsive(verySmall: 6, small: 7, large: 8), 
                            offset: Offset(0, context.responsive(verySmall: 1.5, small: 2, large: 2))
                          )],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(context.responsiveSpacing(
                            verySmall: 10,
                            small: 11,
                            large: 12,
                          )),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                '$emoji ${activity.placeName}',
                                style: TextStyle(
                                  fontSize: context.responsiveFontSize(
                                    verySmall: 14,
                                    small: 15,
                                    large: 16,
                                  ),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: context.responsive(verySmall: 6, small: 7, large: 8)),
                            _TimeChip(text: '${_formatTime(activity.checkInTime)} - ${_formatTime(activity.checkOutTime)}'),
                            SizedBox(width: context.responsive(verySmall: 3, small: 3.5, large: 4)),
                            if (canEdit || canDelete)
                              PopupMenuButton<String>(
                              color: Colors.white,
                              elevation: 6,
                              offset: const Offset(0, 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(color: AppColors.border.withValues(alpha: 0.6)),
                              ),
                              onSelected: (value) {
                                if (value == 'edit' && canEdit) {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: BlocProvider.value(
                                        value: context.read<ScheduleBloc>(),
                                        child: EditActivitySheet(activity: activity, rootContext: context),
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete' && canDelete) {
                                  _confirmDelete(context);
                                }
                              },
                              itemBuilder: (context) => [
                                if (canEdit)
                                  PopupMenuItem(
                                    value: 'edit',
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                        SizedBox(width: 10),
                                        Text('Chỉnh sửa', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                                if (canEdit && canDelete) const PopupMenuDivider(height: 4),
                                if (canDelete)
                                  PopupMenuItem(
                                    value: 'delete',
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                        SizedBox(width: 10),
                                        Text('Xoá', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                  ),
                              ],
                              child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 6,
                          small: 7,
                          large: 8,
                        )),
                        
                        // Location with better visibility
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(context.responsiveSpacing(
                            verySmall: 8,
                            small: 9,
                            large: 10,
                          )),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                              verySmall: 6,
                              small: 7,
                              large: 8,
                            )),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: context.responsiveIconSize(
                                  verySmall: 14,
                                  small: 15,
                                  large: 16,
                                ),
                                color: AppColors.primary,
                              ),
                              SizedBox(width: context.responsive(verySmall: 6, small: 7, large: 8)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Địa chỉ',
                                      style: TextStyle(
                                        fontSize: context.responsiveFontSize(
                                          verySmall: 10,
                                          small: 10.5,
                                          large: 11,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: context.responsive(verySmall: 1.5, small: 2, large: 2)),
                                    Text(
                                      activity.location,
                                      style: TextStyle(
                                        fontSize: context.responsiveFontSize(
                                          verySmall: 12,
                                          small: 12.5,
                                          large: 13,
                                        ),
                                        color: AppColors.textPrimary,
                                        height: 1.3,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        if (activity.description.isNotEmpty) ...[
                          SizedBox(height: context.responsiveSpacing(
                            verySmall: 6,
                            small: 7,
                            large: 8,
                          )),
                          Container(
                            padding: EdgeInsets.all(context.responsiveSpacing(
                              verySmall: 6,
                              small: 7,
                              large: 8,
                            )),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                                verySmall: 6,
                                small: 7,
                                large: 8,
                              )),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notes_rounded, 
                                  size: context.responsiveIconSize(
                                    verySmall: 12,
                                    small: 13,
                                    large: 14,
                                  ), 
                                  color: AppColors.textSecondary
                                ),
                                SizedBox(width: context.responsive(verySmall: 5, small: 5.5, large: 6)),
                                Expanded(
                                  child: Text(
                                    activity.description,
                                    style: TextStyle(
                                      fontSize: context.responsiveFontSize(
                                        verySmall: 11,
                                        small: 11.5,
                                        large: 12,
                                      ),
                                      color: AppColors.textSecondary,
                                      height: 1.3
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        
                        SizedBox(height: context.responsiveSpacing(
                          verySmall: 6,
                          small: 7,
                          large: 8,
                        )),
                        Row(
                          children: [
                            // Attendance status badges
                            if (activity.attendanceStatus == 'CheckOut') ...[
                              // Show both CheckIn and CheckOut when completed
                              _AttendanceStatusChip(status: 'CheckIn'),
                              const SizedBox(width: 6),
                              _AttendanceStatusChip(status: 'CheckOut'),
                              const SizedBox(width: 8),
                            ] else if (activity.attendanceStatus.isNotEmpty) ...[
                              // Show single status for CheckIn only
                              _AttendanceStatusChip(status: activity.attendanceStatus),
                              const SizedBox(width: 8),
                            ],
                            const Spacer(),
                            _TagChip(text: '#${activity.orderIndex}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      );
        },
      ),
    );
  }

  static final DateFormat _timeFmt = DateFormat('HH:mm');

  String _formatTime(DateTime dateTime) {
    return _timeFmt.format(dateTime);
  }

  String _calculateDuration() {
    final duration = activity.checkOutTime.difference(activity.checkInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }


  String _guessEmoji(ActivityEntity a) {
    final t = '${a.placeName} ${a.description}'.toLowerCase();
    if (t.contains('cà phê') || t.contains('coffee')) return '☕️';
    if (t.contains('ăn') || t.contains('nhà hàng') || t.contains('food')) return '🍽️';
    if (t.contains('bar') || t.contains('pub')) return '🍹';
    if (t.contains('chụp') || t.contains('check-in')) return '📸';
    if (t.contains('đi bộ') || t.contains('hiking')) return '🥾';
    return '📍';
  }


  void _showCheckInOptionsModal(BuildContext context) {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: scheduleBloc,
        child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-in/Check-out',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activity.placeName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildCheckInOptionButton(
                          context,
                          icon: Icons.login,
                          title: 'Check-in',
                          subtitle: 'Tham gia hoạt động',
                          color: AppColors.success,
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            _showCheckInModal(bottomSheetContext, true, scheduleBloc: scheduleBloc);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCheckInOptionButton(
                          context,
                          icon: Icons.logout,
                          title: 'Check-out',
                          subtitle: 'Kết thúc hoạt động',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.pop(bottomSheetContext);
                            _showCheckInModal(bottomSheetContext, false, scheduleBloc: scheduleBloc);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Gallery button
                  SizedBox(
                    width: double.infinity,
                    child: _buildCheckInOptionButton(
                      context,
                      icon: Icons.photo_library,
                      title: 'Xem ảnh hoạt động',
                      subtitle: 'Xem hình ảnh của hoạt động',
                      color: AppColors.accent,
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider(
                              create: (context) => di.sl<ScheduleBloc>(),
                              child: ActivityMediaGallery(
                                activityId: activity.id,
                                activityTitle: activity.placeName,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildCheckInOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckInModal(BuildContext context, bool isCheckIn, {ScheduleBloc? scheduleBloc}) {
    final bloc = scheduleBloc ?? context.read<ScheduleBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: CheckInModal(
          activityId: activity.id,
          isCheckIn: isCheckIn,
          attendanceStatus: activity.attendanceStatus,
          onSuccess: () {
            bloc.add(
              RefreshActivitiesEvent(
                scheduleId: activity.scheduleId,
                date: selectedDate,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá hoạt động?'),
        content: const Text('Bạn có chắc chắn muốn xoá hoạt động này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<ScheduleBloc>().add(DeleteActivityEvent(
        activityId: activity.id, 
        scheduleId: activity.scheduleId,
        date: selectedDate,
      ));
    }
  }
}

class _DashedLinePaint extends StatelessWidget {
  final Color color;
  const _DashedLinePaint({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _VerticalDashedLinePainter(color: color),
      size: const Size(2, double.infinity),
    );
  }
}

class _VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  static const double dashHeight = 5.0;
  static const double gap = 3.0;

  const _VerticalDashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.square;

    double y = 0;
    while (y < size.height) {
      final endY = (y + dashHeight).clamp(0.0, size.height);
      canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, endY), paint);
      y += dashHeight + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalDashedLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TimeChip extends StatelessWidget {
  final String text;
  const _TimeChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }
}

class _AttendanceStatusChip extends StatelessWidget {
  final String status;
  const _AttendanceStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String displayText;
    IconData icon;

    switch (status) {
      case 'CheckIn':
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        displayText = 'Đã Check-in';
        icon = Icons.login;
        break;
      case 'CheckOut':
        backgroundColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        displayText = 'Đã Check-out';
        icon = Icons.logout;
        break;
      default:
        backgroundColor = AppColors.background;
        textColor = AppColors.textSecondary;
        displayText = 'Chưa tham gia';
        icon = Icons.access_time;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 10,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
