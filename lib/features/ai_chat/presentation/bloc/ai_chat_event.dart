import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/activity_request_entity.dart';
import '../../domain/entities/schedule_data_entity.dart';

abstract class AIChatEvent {}

class SendMessage extends AIChatEvent {
  final String message;

  SendMessage({required this.message});
}

class AddUserMessage extends AIChatEvent {
  final String message;

  AddUserMessage({required this.message});
}

class AddAIMessage extends AIChatEvent {
  final ChatMessageEntity message;

  AddAIMessage({required this.message});
}

class ClearChat extends AIChatEvent {}

class StartTyping extends AIChatEvent {}

class StopTyping extends AIChatEvent {}

class AddListActivities extends AIChatEvent {
  final List<ActivityRequestEntity> activities;

  AddListActivities({required this.activities});
}

class CreateSchedule extends AIChatEvent {
  final ScheduleDataEntity scheduleData;

  CreateSchedule({required this.scheduleData});
}
