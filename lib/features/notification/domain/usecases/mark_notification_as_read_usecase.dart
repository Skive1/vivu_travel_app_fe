import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;

  MarkNotificationAsReadUseCase({required this.repository});

  Future<void> call(String notificationRecipientId) async {
    return await repository.markNotificationAsRead(notificationRecipientId);
  }
}
