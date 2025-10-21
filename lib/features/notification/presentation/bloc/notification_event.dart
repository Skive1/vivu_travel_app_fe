import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class GetNotificationsEvent extends NotificationEvent {
  const GetNotificationsEvent();
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationRecipientId;

  const MarkNotificationAsReadEvent({required this.notificationRecipientId});

  @override
  List<Object?> get props => [notificationRecipientId];
}
