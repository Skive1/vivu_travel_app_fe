import '../entities/schedule_entity.dart';
import '../entities/activity_entity.dart';
import '../../data/models/create_schedule_request.dart';
import '../../data/models/update_schedule_request.dart';
import '../../data/models/create_activity_request.dart';
import '../../data/models/update_activity_request.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedulesByParticipant(String participantId);
  Future<List<ActivityEntity>> getActivitiesBySchedule(String scheduleId);
  Future<String> shareSchedule(String scheduleId);
  Future<ScheduleEntity> createSchedule(CreateScheduleRequest request);
  Future<ScheduleEntity> updateSchedule(String scheduleId, UpdateScheduleRequest request);
  Future<ActivityEntity> addActivity(CreateActivityRequest request);
  Future<ActivityEntity> updateActivity(int activityId, UpdateActivityRequest request);
  Future<void> deleteActivity(int activityId);
}
