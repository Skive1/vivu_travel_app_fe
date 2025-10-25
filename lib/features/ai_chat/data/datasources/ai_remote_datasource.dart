import 'package:dio/dio.dart';
import '../../../../core/network/endpoints.dart';
import '../models/ai_request_model.dart';
import '../models/ai_response_model.dart';
import '../models/activity_request_model.dart';
import '../models/activity_response_model.dart';
import '../../../../core/errors/exceptions.dart';
import 'dart:convert';

abstract class AIRemoteDataSource {
  Future<AIResponseModel> sendMessage(AIRequestModel request);
  Future<List<ActivityResponseModel>> addListActivities(List<ActivityRequestModel> activities);
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final Dio _dio;

  AIRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<AIResponseModel> sendMessage(AIRequestModel request) async {
    try {
      final response = await _dio.post(
        Endpoints.aiChat,
        data: jsonEncode(request.message),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          receiveTimeout: const Duration(seconds: 60), // 60 giây cho AI response
          sendTimeout: const Duration(seconds: 30),    // 30 giây cho request
        ),
      );

      if (response.statusCode == 200) {
        return AIResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to get AI response');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ServerException('Bad request: ${e.response?.data ?? e.message}');
      } else if (e.response?.statusCode == 401) {
        throw ServerException('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 500) {
        throw ServerException('Server error: Please try again later');
      } else {
        throw ServerException('Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<ActivityResponseModel>> addListActivities(List<ActivityRequestModel> activities) async {
    try {
      // Debug: Log request data
      print('🔵 [DEBUG] AddListActivities API Request:');
      print('🔵 [DEBUG] Endpoint: ${Endpoints.addListActivities}');
      print('🔵 [DEBUG] Activities count: ${activities.length}');
      print('🔵 [DEBUG] Request data:');
      for (int i = 0; i < activities.length; i++) {
        final activity = activities[i];
        print('🔵 [DEBUG] Activity $i:');
        print('🔵 [DEBUG]   - placeName: ${activity.placeName}');
        print('🔵 [DEBUG]   - location: ${activity.location}');
        print('🔵 [DEBUG]   - latitude: ${activity.latitude}');
        print('🔵 [DEBUG]   - longitude: ${activity.longitude}');
        print('🔵 [DEBUG]   - description: ${activity.description}');
        print('🔵 [DEBUG]   - checkInTime: ${activity.checkInTime}');
        print('🔵 [DEBUG]   - checkOutTime: ${activity.checkOutTime}');
        print('🔵 [DEBUG]   - orderIndex: ${activity.orderIndex}');
        print('🔵 [DEBUG]   - scheduleId: ${activity.scheduleId}');
        print('🔵 [DEBUG]   - JSON: ${jsonEncode(activity.toJson())}');
      }

      final response = await _dio.post(
        Endpoints.addListActivities,
        data: activities.map((activity) => activity.toJson()).toList(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      // Debug: Log response data
      print('🟢 [DEBUG] AddListActivities API Response:');
      print('🟢 [DEBUG] Status Code: ${response.statusCode}');
      print('🟢 [DEBUG] Response Headers: ${response.headers}');
      print('🟢 [DEBUG] Response Data: ${jsonEncode(response.data)}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final result = data.map((json) => ActivityResponseModel.fromJson(json)).toList();
        
        // Debug: Log parsed result
        print('🟢 [DEBUG] Parsed Activities Response:');
        for (int i = 0; i < result.length; i++) {
          final activity = result[i];
          print('🟢 [DEBUG] Response Activity $i:');
          print('🟢 [DEBUG]   - id: ${activity.id}');
          print('🟢 [DEBUG]   - placeName: ${activity.placeName}');
          print('🟢 [DEBUG]   - location: ${activity.location}');
          print('🟢 [DEBUG]   - scheduleId: ${activity.scheduleId}');
          print('🟢 [DEBUG]   - checkInTime: ${activity.checkInTime}');
          print('🟢 [DEBUG]   - checkOutTime: ${activity.checkOutTime}');
          print('🟢 [DEBUG]   - orderIndex: ${activity.orderIndex}');
        }
        
        return result;
      } else {
        print('🔴 [DEBUG] AddListActivities API Error:');
        print('🔴 [DEBUG] Status Code: ${response.statusCode}');
        print('🔴 [DEBUG] Response Data: ${jsonEncode(response.data)}');
        throw ServerException('Failed to add activities');
      }
    } on DioException catch (e) {
      print('🔴 [DEBUG] AddListActivities DioException:');
      print('🔴 [DEBUG] Error Type: ${e.type}');
      print('🔴 [DEBUG] Error Message: ${e.message}');
      print('🔴 [DEBUG] Response Data: ${e.response?.data}');
      print('🔴 [DEBUG] Status Code: ${e.response?.statusCode}');
      print('🔴 [DEBUG] Headers: ${e.response?.headers}');
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      print('🔴 [DEBUG] AddListActivities Unexpected Error:');
      print('🔴 [DEBUG] Error: $e');
      print('🔴 [DEBUG] Stack Trace: ${StackTrace.current}');
      throw ServerException('Unexpected error: $e');
    }
  }
}
