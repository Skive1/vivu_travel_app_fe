import 'schedule_data_entity.dart';
import 'activity_data_entity.dart';

class AIResponseEntity {
  final bool success;
  final String message;
  final String timestamp;
  final String aiMessage;
  final ScheduleDataEntity? scheduleData;
  final List<ActivityDataEntity>? activitiesData;

  const AIResponseEntity({
    required this.success,
    required this.message,
    required this.timestamp,
    required this.aiMessage,
    this.scheduleData,
    this.activitiesData,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AIResponseEntity &&
        other.success == success &&
        other.message == message &&
        other.timestamp == timestamp &&
        other.aiMessage == aiMessage &&
        other.scheduleData == scheduleData &&
        other.activitiesData == activitiesData;
  }

  @override
  int get hashCode {
    return Object.hash(
      success,
      message,
      timestamp,
      aiMessage,
      scheduleData,
      activitiesData,
    );
  }
}
