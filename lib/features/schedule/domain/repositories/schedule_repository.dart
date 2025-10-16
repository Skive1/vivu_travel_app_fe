import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entity.dart';
import '../entities/activity_entity.dart';
import '../entities/kick_participant_result.dart';
import '../../data/models/create_schedule_request.dart';
import '../../data/models/update_schedule_request.dart';
import '../../data/models/create_activity_request.dart';
import '../../data/models/update_activity_request.dart';
import '../../data/models/join_schedule_request.dart';
import '../../data/models/join_schedule_response.dart';
import '../../data/models/add_participant_by_email_request.dart';
import '../../data/models/add_participant_by_email_response.dart';
import '../entities/participant_entity.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedulesByParticipant(String participantId);
  Future<Either<Failure, ScheduleEntity>> getScheduleById(String scheduleId);
  Future<List<ActivityEntity>> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  );
  Future<String> shareSchedule(String scheduleId);
  Future<ScheduleEntity> createSchedule(CreateScheduleRequest request);
  Future<ScheduleEntity> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  );
  Future<ActivityEntity> addActivity(CreateActivityRequest request);
  Future<ActivityEntity> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  );
  Future<void> deleteActivity(int activityId);
  Future<Either<Failure, JoinScheduleResponse>> joinSchedule(JoinScheduleRequest request);
  Future<Either<Failure, List<ParticipantEntity>>> getScheduleParticipants(String scheduleId);
  Future<Either<Failure, AddParticipantByEmailResponse>> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request);
  Future<Either<Failure, KickParticipantResult>> kickParticipant(String scheduleId, String participantId);
  Future<Either<Failure, KickParticipantResult>> leaveSchedule(String scheduleId, String userId);
  Future<Either<Failure, Unit>> changeParticipantRole(String scheduleId, String participantId);
  Future<Either<Failure, Unit>> reorderActivity({required int newIndex, required int activityId});
}
