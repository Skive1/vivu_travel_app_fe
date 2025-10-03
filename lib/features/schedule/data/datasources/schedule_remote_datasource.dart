import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/schedule_model.dart';
import '../models/activity_model.dart';
import '../models/share_schedule_response.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<ScheduleModel>> getSchedulesByParticipant(String participantId);
  Future<List<ActivityModel>> getActivitiesBySchedule(String scheduleId);
  Future<ShareScheduleResponse> shareSchedule(String scheduleId);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient _apiClient;

  ScheduleRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

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
}
