import 'package:flutter/material.dart';

import 'schedule_content.dart';

class ScheduleContainer extends StatelessWidget {
  final String? scheduleId;

  const ScheduleContainer({super.key, this.scheduleId});

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
      child: ScheduleContent(scheduleId: scheduleId),
    );
  }
}
