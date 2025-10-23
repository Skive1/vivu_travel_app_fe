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

// SignalR Events
class InitializeSignalREvent extends NotificationEvent {
  const InitializeSignalREvent();
}

class StartSignalREvent extends NotificationEvent {
  const StartSignalREvent();
}

class StopSignalREvent extends NotificationEvent {
  const StopSignalREvent();
}

class JoinUserGroupEvent extends NotificationEvent {
  final String userId;

  const JoinUserGroupEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class JoinScheduleGroupEvent extends NotificationEvent {
  final String scheduleId;

  const JoinScheduleGroupEvent({required this.scheduleId});

  @override
  List<Object?> get props => [scheduleId];
}

class LeaveGroupEvent extends NotificationEvent {
  final String groupId;

  const LeaveGroupEvent({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class SignalRNotificationReceivedEvent extends NotificationEvent {
  final Map<String, dynamic> notification;

  const SignalRNotificationReceivedEvent({required this.notification});

  @override
  List<Object?> get props => [notification];
}
