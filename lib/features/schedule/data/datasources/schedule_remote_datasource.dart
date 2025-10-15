import 'package:dio/dio.dart';
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
  Future<void> changeParticipantRole(String scheduleId, String participantId);
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
        return (response.data as List)
            .map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>))
            .toList();
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

      // DEBUG: Log the raw API response
      print('DEBUG[DataSource]: GET /api/schedule/$scheduleId response:');
      print('DEBUG[DataSource]: Status Code: ${response.statusCode}');
      print('DEBUG[DataSource]: Response Data: ${response.data}');
      
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        print('DEBUG[DataSource]: participantRole in response: ${data['participantRole']}');
        return ScheduleModel.fromJson(data);
      }

      throw Exception('Invalid response format');
    } on DioException catch (e) {
      print('DEBUG[DataSource]: DioException in getScheduleById: ${e.message}');
      print('DEBUG[DataSource]: Response data: ${e.response?.data}');
      throw Exception('Failed to get schedule: ${e.message}');
    }
  }

  @override
  Future<ActivitiesResponse> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  ) async {
    try {
      // Format date as ISO 8601 (2025-10-09T00:00:00)
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}T00:00:00';

      final response = await _apiClient.get(
        Endpoints.getActivitiesBySchedule(scheduleId, formattedDate),
      );

      if (response.data is Map<String, dynamic>) {
        return ActivitiesResponse.fromJson(response.data as Map<String, dynamic>);
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
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
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
      return ActivityModel.fromJson(response.data as Map<String, dynamic>);
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

      return ShareScheduleResponse.fromJson(
        response.data as Map<String, dynamic>,
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

      return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
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

      return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
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

      return JoinScheduleResponse.fromJson(response.data as Map<String, dynamic>);
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
        return (response.data as List)
            .map((json) => ParticipantModel.fromJson(json as Map<String, dynamic>))
            .toList();
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

      return AddParticipantByEmailResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to add participant: ${e.message}');
    }
  }

  @override
  Future<KickParticipantResponse> kickParticipant(String scheduleId, String participantId) async {
    try {
      print('DEBUG[DataSource]: Starting kick participant API call');
      print('DEBUG[DataSource]: scheduleId = $scheduleId');
      print('DEBUG[DataSource]: participantId = $participantId');
      
      final response = await _apiClient.patch(
        Endpoints.kickParticipant(scheduleId, participantId),
      );
      
      print('DEBUG[DataSource]: API response received');
      print('DEBUG[DataSource]: Status code: ${response.statusCode}');
      print('DEBUG[DataSource]: Response data type: ${response.data.runtimeType}');
      print('DEBUG[DataSource]: Response data: ${response.data}');
      
      // Response contains participantCounts and scheduleParticipantResponses
      final data = response.data as Map<String, dynamic>;
      print('DEBUG[DataSource]: Cast to Map successful');
      
      final result = KickParticipantResponse.fromJson(data);
      print('DEBUG[DataSource]: KickParticipantResponse created successfully');
      print('DEBUG[DataSource]: participantCounts = ${result.participantCounts}');
      print('DEBUG[DataSource]: participants count = ${result.scheduleParticipantResponses.length}');
      
      return result;
    } on DioException catch (e) {
      print('DEBUG[DataSource]: DioException occurred');
      print('DEBUG[DataSource]: Error message: ${e.message}');
      print('DEBUG[DataSource]: Response data: ${e.response?.data}');
      print('DEBUG[DataSource]: Status code: ${e.response?.statusCode}');
      throw Exception('Failed to kick participant: ${e.message}');
    } catch (e, stackTrace) {
      print('DEBUG[DataSource]: Unexpected error occurred');
      print('DEBUG[DataSource]: Error: $e');
      print('DEBUG[DataSource]: Stack trace: $stackTrace');
      throw Exception('Failed to kick participant: $e');
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
}
