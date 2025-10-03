import '../entities/schedule_entity.dart';
import '../entities/activity_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedulesByParticipant(String participantId);
  Future<List<ActivityEntity>> getActivitiesBySchedule(String scheduleId);
  Future<String> shareSchedule(String scheduleId);
}
