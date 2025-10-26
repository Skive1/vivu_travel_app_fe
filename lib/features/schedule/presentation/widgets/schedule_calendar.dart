import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

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
    final marginValue = context.responsive(
      verySmall: 12.0,
      small: 14.0,
      large: 16.0,
    );
    final paddingValue = context.responsive(
      verySmall: 14.0,
      small: 16.0,
      large: 20.0,
    );
    
    return Container(
      margin: EdgeInsets.all(marginValue),
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
          verySmall: 16.0,
          small: 18.0,
          large: 20.0,
        )),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: context.responsive(
              verySmall: 8.0,
              small: 9.0,
              large: 10.0,
            ),
            offset: Offset(
              0,
              context.responsive(verySmall: 1.5, small: 2.0, large: 2.0),
            ),
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
                  icon: Icon(
                    Icons.chevron_left,
                    color: AppColors.textPrimary,
                    size: context.responsiveIconSize(
                      verySmall: 20.0,
                      small: 22.0,
                      large: 24.0,
                    ),
                  ),
                ),
                Text(
                  _getWeekRangeText(),
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(
                      verySmall: 16.0,
                      small: 17.0,
                      large: 18.0,
                    ),
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
                  icon: Icon(
                    Icons.chevron_right,
                    color: AppColors.textPrimary,
                    size: context.responsiveIconSize(
                      verySmall: 20.0,
                      small: 22.0,
                      large: 24.0,
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: context.responsiveSpacing(
              verySmall: 12.0,
              small: 14.0,
              large: 16.0,
            )),
            
            // Week calendar row with weekday + date chips
            _buildWeekRow(),
          ],
        ),
    );
  }

  Widget _buildWeekRow() {
    // Start of week (Monday)
    final startOfWeek = _getStartOfWeek(_currentWeek);

    return Builder(
      builder: (context) {
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
                  margin: EdgeInsets.symmetric(
                    horizontal: context.responsive(verySmall: 2.0, small: 3.0, large: 4.0),
                    vertical: context.responsive(verySmall: 1.0, small: 1.5, large: 2.0),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: context.responsive(verySmall: 6.0, small: 7.0, large: 8.0),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentOrange
                        : (isToday ? AppColors.accentOrange.withValues(alpha: 0.1) : Colors.transparent),
                    borderRadius: BorderRadius.circular(context.responsiveBorderRadius(
                      verySmall: 12.0,
                      small: 13.0,
                      large: 14.0,
                    )),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppColors.accentOrange,
                            width: context.responsive(verySmall: 1.5, small: 1.8, large: 2.0),
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
                          fontSize: context.responsiveFontSize(
                            verySmall: 10.0,
                            small: 11.0,
                            large: 12.0,
                          ),
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isToday ? AppColors.accentOrange : AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(height: context.responsive(
                        verySmall: 4.0,
                        small: 5.0,
                        large: 6.0,
                      )),
                      // Date number with today indicator
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 14.0,
                                small: 15.0,
                                large: 16.0,
                              ),
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
      },
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
