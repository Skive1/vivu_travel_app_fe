import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/activity_response_entity.dart';
import '../../../schedule/domain/entities/schedule_entity.dart';

abstract class AIChatState {}

class AIChatInitial extends AIChatState {}

class AIChatLoading extends AIChatState {}

class AIChatSuccess extends AIChatState {
  final List<ChatMessageEntity> messages;

  AIChatSuccess({required this.messages});
}

class AIChatError extends AIChatState {
  final String message;

  AIChatError({required this.message});
}

class AIChatTyping extends AIChatState {
  final List<ChatMessageEntity> messages;

  AIChatTyping({required this.messages});
}

class AIChatActivitiesLoading extends AIChatState {
  final List<ChatMessageEntity> messages;

  AIChatActivitiesLoading({required this.messages});
}

class AIChatActivitiesSuccess extends AIChatState {
  final List<ChatMessageEntity> messages;
  final List<ActivityResponseEntity> activities;

  AIChatActivitiesSuccess({
    required this.messages,
    required this.activities,
  });
}

class AIChatActivitiesError extends AIChatState {
  final List<ChatMessageEntity> messages;
  final String message;

  AIChatActivitiesError({
    required this.messages,
    required this.message,
  });
}

class AIChatScheduleLoading extends AIChatState {
  final List<ChatMessageEntity> messages;

  AIChatScheduleLoading({required this.messages});
}

class AIChatScheduleSuccess extends AIChatState {
  final List<ChatMessageEntity> messages;
  final ScheduleEntity schedule;

  AIChatScheduleSuccess({
    required this.messages,
    required this.schedule,
  });
}

class AIChatScheduleError extends AIChatState {
  final List<ChatMessageEntity> messages;
  final String message;

  AIChatScheduleError({
    required this.messages,
    required this.message,
  });
}
