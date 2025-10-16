import 'package:dio/dio.dart';
import '../../../../core/utils/compute_utils.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/schedule_model.dart';
import '../models/activity_model.dart';
import '../models/share_schedule_response.dart';
import '../models/create_schedule_request.dart';
import '../models/update_schedule_request.dart';
import '../models/create_activity_request.dart';
import '../models/update_activity_request.dart';
import '../models/join_schedule_request.dart';
import '../models/join_schedule_response.dart';
import '../models/add_participant_by_email_request.dart';
import '../models/add_participant_by_email_response.dart';
import '../models/participant_model.dart';
import '../models/activities_response.dart';
import '../models/kick_participant_response.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedulesByParticipant(String participantId);
  Future<ScheduleModel> getScheduleById(String scheduleId);
  Future<ActivitiesResponse> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  );
  Future<ActivityModel> addActivity(CreateActivityRequest request);
  Future<ActivityModel> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  );
  Future<void> deleteActivity(int activityId);
  Future<ShareScheduleResponse> shareSchedule(String scheduleId);
  Future<ScheduleModel> createSchedule(CreateScheduleRequest request);
  Future<ScheduleModel> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  );
  Future<JoinScheduleResponse> joinSchedule(JoinScheduleRequest request);
  Future<List<ParticipantModel>> getScheduleParticipants(String scheduleId);
  Future<AddParticipantByEmailResponse> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request);
  Future<KickParticipantResponse> kickParticipant(String scheduleId, String participantId);
  Future<KickParticipantResponse> leaveSchedule(String scheduleId, String userId);
  Future<void> changeParticipantRole(String scheduleId, String participantId);
  Future<void> reorderActivity({required int newIndex, required int activityId});
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient _apiClient;

  ScheduleRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ScheduleModel>> getSchedulesByParticipant(
    String participantId,
  ) async {
    try {
      final response = await _apiClient.get(
        '${Endpoints.getSchedulesByParticipant}/$participantId',
      );

      if (response.data is List) {
        final list = response.data as List;
        // Offload heavy list parsing to background isolate
        return await computeMapList<ScheduleModel>(
          list,
          (m) => ScheduleModel.fromJson(m),
        );
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to get schedules: ${e.message}');
    }
  }

  @override
  Future<ScheduleModel> getScheduleById(String scheduleId) async {
    try {
      final response = await _apiClient.get(
        Endpoints.getScheduleById(scheduleId),
      );
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // Offload object parsing if payload is large
        return await computeParseObject<ScheduleModel>(
          data,
          (m) => ScheduleModel.fromJson(m),
        );
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to get schedule: ${e.message}');
    }
  }

  @override
  Future<ActivitiesResponse> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  ) async {
    try {
      final t0 = DateTime.now();
      // Format date as ISO 8601 (2025-10-09T00:00:00)
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00';

      final response = await _apiClient.get(
        Endpoints.getActivitiesBySchedule(scheduleId, formattedDate),
      );
      final t1 = DateTime.now();
      // ignore: avoid_print
      print('[TIMING][DS] API activities took ${t1.difference(t0).inMilliseconds}ms');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final parsed = await computeParseObject<ActivitiesResponse>(
          data,
          (m) => ActivitiesResponse.fromJson(m),
        );
        final t2 = DateTime.now();
        print('[TIMING][DS] parse activities took ${t2.difference(t1).inMilliseconds}ms');
        return parsed;
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to get activities: ${e.message}');
    }
  }

  @override
  Future<ActivityModel> addActivity(CreateActivityRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.addActivity,
        data: request.toJson(),
      );
      return await computeParseObject<ActivityModel>(
        response.data as Map<String, dynamic>,
        (m) => ActivityModel.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to add activity: ${e.message}');
    }
  }

  @override
  Future<ActivityModel> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${Endpoints.activities}/$activityId',
        data: request.toJson(),
      );
      return await computeParseObject<ActivityModel>(
        response.data as Map<String, dynamic>,
        (m) => ActivityModel.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to update activity: ${e.message}');
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    try {
      await _apiClient.delete('${Endpoints.activities}/$activityId');
    } on DioException catch (e) {
      throw Exception('Failed to delete activity: ${e.message}');
    }
  }

  @override
  Future<ShareScheduleResponse> shareSchedule(String scheduleId) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.shareSchedule}/$scheduleId',
      );

      return await computeParseObject<ShareScheduleResponse>(
        response.data as Map<String, dynamic>,
        (m) => ShareScheduleResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to share schedule: ${e.message}');
    }
  }

  @override
  Future<ScheduleModel> createSchedule(CreateScheduleRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.createSchedule,
        data: request.toJson(),
      );

      return await computeParseObject<ScheduleModel>(
        response.data as Map<String, dynamic>,
        (m) => ScheduleModel.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to create schedule: ${e.message}');
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${Endpoints.updateSchedule}/$scheduleId',
        data: request.toJson(),
      );

      return await computeParseObject<ScheduleModel>(
        response.data as Map<String, dynamic>,
        (m) => ScheduleModel.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to update schedule: ${e.message}');
    }
  }

  @override
  Future<JoinScheduleResponse> joinSchedule(JoinScheduleRequest request) async {
    try {
      final response = await _apiClient.post(
        Endpoints.joinSchedule,
        data: request.toJson(),
      );

      return await computeParseObject<JoinScheduleResponse>(
        response.data as Map<String, dynamic>,
        (m) => JoinScheduleResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to join schedule: ${e.message}');
    }
  }

  @override
  Future<List<ParticipantModel>> getScheduleParticipants(String scheduleId) async {
    try {
      final response = await _apiClient.get(
        Endpoints.getScheduleParticipants(scheduleId),
      );

      if (response.data is List) {
        final list = response.data as List;
        return await computeMapList<ParticipantModel>(
          list,
          (m) => ParticipantModel.fromJson(m),
        );
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      throw Exception('Failed to get participants: ${e.message}');
    }
  }

  @override
  Future<AddParticipantByEmailResponse> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request) async {
    try {
      final response = await _apiClient.post(
        '${Endpoints.addParticipantByEmail(scheduleId)}?email=${Uri.encodeComponent(request.email)}',
      );

      return await computeParseObject<AddParticipantByEmailResponse>(
        response.data as Map<String, dynamic>,
        (m) => AddParticipantByEmailResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to add participant: ${e.message}');
    }
  }

  @override
  Future<KickParticipantResponse> kickParticipant(String scheduleId, String participantId) async {
    try {
      final response = await _apiClient.patch(
        Endpoints.kickParticipant(scheduleId, participantId),
      );

      // Response contains participantCounts and scheduleParticipantResponses
      final data = response.data as Map<String, dynamic>;
      return await computeParseObject<KickParticipantResponse>(
        data,
        (m) => KickParticipantResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to kick participant: ${e.message}');
    } catch (e) {
      throw Exception('Failed to kick participant: $e');
    }
  }

  @override
  Future<KickParticipantResponse> leaveSchedule(String scheduleId, String userId) async {
    try {
      final response = await _apiClient.post(
        Endpoints.leaveParticipant(scheduleId, userId),
      );

      final data = response.data as Map<String, dynamic>;
      return await computeParseObject<KickParticipantResponse>(
        data,
        (m) => KickParticipantResponse.fromJson(m),
      );
    } on DioException catch (e) {
      throw Exception('Failed to leave schedule: ${e.message}');
    } catch (e) {
      throw Exception('Failed to leave schedule: $e');
    }
  }

  @override
  Future<void> changeParticipantRole(String scheduleId, String participantId) async {
    try {
      await _apiClient.patch(
        Endpoints.changeParticipantRole(scheduleId, participantId),
      );
    } on DioException catch (e) {
      throw Exception('Failed to change participant role: ${e.message}');
    }
  }

  @override
  Future<void> reorderActivity({required int newIndex, required int activityId}) async {
    try {
      await _apiClient.put(Endpoints.reorderActivity(newIndex, activityId));
    } on DioException catch (e) {
      throw Exception('Failed to reorder activity: ${e.message}');
    }
  }
}
