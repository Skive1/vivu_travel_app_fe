import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase({required this.repository});

  Future<List<NotificationEntity>> call() async {
    return await repository.getNotifications();
  }
}
