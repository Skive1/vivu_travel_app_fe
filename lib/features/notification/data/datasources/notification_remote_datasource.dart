import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markNotificationAsRead(String notificationRecipientId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;

  NotificationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await apiClient.get(Endpoints.getNotifications);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data as List<dynamic>;
        return jsonList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationRecipientId) async {
    try {
      final response = await apiClient.put(
        '${Endpoints.markNotificationAsRead}?notificationRecipientId=$notificationRecipientId',
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
