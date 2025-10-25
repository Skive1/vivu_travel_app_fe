import 'package:flutter/material.dart';

import 'schedule_list.dart';

class ScheduleContainer extends StatelessWidget {
  final String? scheduleId;
  final DateTime selectedDate;
  final String? currentUserId;
  final String? ownerId;

  const ScheduleContainer({
    super.key, 
    this.scheduleId,
    required this.selectedDate,
    this.currentUserId,
    this.ownerId,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final availableHeight = screenSize.height - appBarHeight - statusBarHeight;
    
    return Container(
      width: screenSize.width,
      height: availableHeight,
      constraints: BoxConstraints(
        maxHeight: availableHeight,
        minHeight: availableHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ScheduleList(
        selectedDate: selectedDate,
        scheduleId: scheduleId,
        currentUserId: currentUserId,
        ownerId: ownerId,
      ),
    );
  }
}
