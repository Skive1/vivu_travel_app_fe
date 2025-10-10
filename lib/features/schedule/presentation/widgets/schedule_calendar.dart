import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class ScheduleCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  
  const ScheduleCalendar({
    super.key,
    required this.onDateSelected,
  });

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentWeek = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
        child: Column(
          children: [
            // Week navigation header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentWeek = _currentWeek.subtract(const Duration(days: 7));
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _getWeekRangeText(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentWeek = _currentWeek.add(const Duration(days: 7));
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Week calendar row with weekday + date chips
            _buildWeekRow(),
          ],
        ),
    );
  }

  Widget _buildWeekRow() {
    // Start of week (Monday)
    final startOfWeek = _getStartOfWeek(_currentWeek);

    return Row(
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final isSelected = _selectedDate.year == date.year &&
            _selectedDate.month == date.month &&
            _selectedDate.day == date.day;
        final isToday = DateTime.now().year == date.year &&
            DateTime.now().month == date.month &&
            DateTime.now().day == date.day;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              widget.onDateSelected(date);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentOrange
                    : (isToday ? AppColors.accentOrange.withValues(alpha: 0.1) : Colors.transparent),
                borderRadius: BorderRadius.circular(14),
                border: isToday && !isSelected
                    ? Border.all(
                        color: AppColors.accentOrange,
                        width: 2,
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Weekday label
                  Text(
                    _weekdayLabel(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isToday ? AppColors.accentOrange : AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Date number with today indicator
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.accentOrange : AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String _weekdayLabel(DateTime date) {
    // Map 1..7 to S M T W T F S abbreviations in Vietnamese style
    switch (date.weekday) {
      case DateTime.monday:
        return 'M';
      case DateTime.tuesday:
        return 'T';
      case DateTime.wednesday:
        return 'W';
      case DateTime.thursday:
        return 'T';
      case DateTime.friday:
        return 'F';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
      default:
        return 'S';
    }
  }

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday of the week
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  String _getWeekRangeText() {
    final startOfWeek = _getStartOfWeek(_currentWeek);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    final startDay = startOfWeek.day;
    final endDay = endOfWeek.day;
    final month = startOfWeek.month;
    
    // If it's the same month
    if (startOfWeek.month == endOfWeek.month) {
      return '$startDay - $endDay Tháng $month';
    } else {
      // If it spans two months
      return '$startDay Tháng ${startOfWeek.month} - $endDay Tháng ${endOfWeek.month}';
    }
  }

  // Legacy day box no longer used; kept for reference
}
