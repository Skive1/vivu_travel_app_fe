import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/schedule_model.dart';
import '../models/activity_model.dart';
import '../models/share_schedule_response.dart';
import '../models/create_schedule_request.dart';
import '../models/update_schedule_request.dart';
import '../models/create_activity_request.dart';
import '../models/update_activity_request.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedulesByParticipant(String participantId);
  Future<List<ActivityModel>> getActivitiesBySchedule(String scheduleId);
  Future<ActivityModel> addActivity(CreateActivityRequest request);
  Future<ActivityModel> updateActivity(int activityId, UpdateActivityRequest request);
  Future<void> deleteActivity(int activityId);
  Future<ShareScheduleResponse> shareSchedule(String scheduleId);
  Future<ScheduleModel> createSchedule(CreateScheduleRequest request);
  Future<ScheduleModel> updateSchedule(String scheduleId, UpdateScheduleRequest request);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient _apiClient;

  ScheduleRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  void _d(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }

  @override
  Future<List<ScheduleModel>> getSchedulesByParticipant(String participantId) async {
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
  Future<List<ActivityModel>> getActivitiesBySchedule(String scheduleId) async {
    try {
      final response = await _apiClient.get(
        '${Endpoints.getActivitiesBySchedule}$scheduleId',
      );
      
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ActivityModel.fromJson(json as Map<String, dynamic>))
            .where((activity) => !activity.isDeleted) // Filter out deleted activities
            .toList();
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
  Future<ActivityModel> updateActivity(int activityId, UpdateActivityRequest request) async {
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
      await _apiClient.delete(
        '${Endpoints.activities}/$activityId',
      );
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
      
      return ShareScheduleResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to share schedule: ${e.message}');
    }
  }

  @override
  Future<ScheduleModel> createSchedule(CreateScheduleRequest request) async {
    _d('🌍 ScheduleRemoteDataSource: createSchedule called');
    _d('🌍 Endpoint: ${Endpoints.createSchedule}');
    
    try {
      final response = await _apiClient.post(
        Endpoints.createSchedule,
        data: request.toJson(),
      );
      
      _d('✅ ScheduleRemoteDataSource: API call successful');
      _d('✅ Response status: ${response.statusCode}');
      
      return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _d('❌ ScheduleRemoteDataSource: DioException - ${e.message}');
      _d('❌ Status code: ${e.response?.statusCode}');
      throw Exception('Failed to create schedule: ${e.message}');
    }
  }

  @override
  Future<ScheduleModel> updateSchedule(String scheduleId, UpdateScheduleRequest request) async {
    _d('🌍 ScheduleRemoteDataSource: updateSchedule called');
    _d('🌍 Endpoint: ${Endpoints.updateSchedule}/$scheduleId');
    
    try {
      final response = await _apiClient.put(
        '${Endpoints.updateSchedule}/$scheduleId',
        data: request.toJson(),
      );
      
      _d('✅ ScheduleRemoteDataSource: Update API call successful');
      _d('✅ Response status: ${response.statusCode}');
      
      return ScheduleModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _d('❌ ScheduleRemoteDataSource: Update DioException - ${e.message}');
      _d('❌ Status code: ${e.response?.statusCode}');
      throw Exception('Failed to update schedule: ${e.message}');
    }
  }
}
