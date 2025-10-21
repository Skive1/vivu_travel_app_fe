
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NotificationEntity>> getNotifications() async {
      try {
        final notifications = await remoteDataSource.getNotifications();
        return notifications;
      } catch (e) {
        throw Exception('Failed to fetch notifications: $e');
      }
  }

  @override
  Future<void> markNotificationAsRead(String notificationRecipientId) async {
      try {
        await remoteDataSource.markNotificationAsRead(notificationRecipientId);
      } catch (e) {
        throw Exception('Failed to mark notification as read: $e');
      }
  }
}
