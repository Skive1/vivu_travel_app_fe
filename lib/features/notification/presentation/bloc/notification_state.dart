import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;

  const NotificationLoaded({required this.notifications});

  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

// SignalR States
class SignalRInitializing extends NotificationState {}

class SignalRConnecting extends NotificationState {}

class SignalRConnected extends NotificationState {
  final String? userId;
  final List<String> joinedGroups;

  const SignalRConnected({
    this.userId,
    this.joinedGroups = const [],
  });

  @override
  List<Object?> get props => [userId, joinedGroups];
}

class SignalRDisconnected extends NotificationState {}

class SignalRReconnecting extends NotificationState {}

class SignalRError extends NotificationState {
  final String message;

  const SignalRError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RealTimeNotificationReceived extends NotificationState {
  final Map<String, dynamic> notification;

  const RealTimeNotificationReceived({required this.notification});

  @override
  List<Object?> get props => [notification];
}
