// duplicate import removed
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/activity_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import 'edit_activity_sheet.dart';
import 'package:flutter/material.dart';

class ActivityTimelineItem extends StatelessWidget {
  final ActivityEntity activity;
  final bool isLast;

  const ActivityTimelineItem({
    Key? key,
    required this.activity,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final period = _getPeriodLabel(activity.checkInTime);
    final emoji = _guessEmoji(activity);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                alignment: Alignment.center,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                ),
              ),
              if (!isLast) const _DashedLine(height: 72, color: AppColors.border),
            ],
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '$emoji ${activity.placeName}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _TimeChip(text: '${_formatTime(activity.checkInTime)} - ${_formatTime(activity.checkOutTime)}'),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
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
                            } else if (value == 'delete') {
                              _confirmDelete(context);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Chỉnh sửa')])),
                            PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18), SizedBox(width: 8), Text('Xoá')]))
                          ],
                          child: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        _TagChip(text: period),
                        const SizedBox(width: 8),
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            activity.location,
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (activity.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.notes_rounded, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                activity.description,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text('~ ${_calculateDuration()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const Spacer(),
                        _TagChip(text: '#${activity.orderIndex + 1}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
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

  String _getPeriodLabel(DateTime time) {
    final h = time.hour;
    if (h < 11) return 'Buổi sáng';
    if (h < 14) return 'Buổi trưa';
    if (h < 18) return 'Buổi chiều';
    return 'Buổi tối';
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
      context.read<ScheduleBloc>().add(DeleteActivityEvent(activityId: activity.id, scheduleId: activity.scheduleId));
    }
  }
}

class _DashedLine extends StatelessWidget {
  final double height;
  final Color color;
  const _DashedLine({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    const dashHeight = 5.0;
    const gap = 3.0;
    final dashCount = (height / (dashHeight + gap)).floor();
    return SizedBox(
      width: 2,
      height: height,
      child: Column(
        children: List.generate(dashCount, (_) => Container(height: dashHeight, width: 2, color: color)).expand((w) sync* {
          yield w;
          yield const SizedBox(height: gap);
        }).toList(),
      ),
    );
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
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
