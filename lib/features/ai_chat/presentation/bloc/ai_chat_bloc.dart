import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/ai_request_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/send_ai_message.dart';
import '../../domain/usecases/add_list_activities.dart' as usecase;
import '../../domain/usecases/create_schedule_from_ai.dart';
import 'ai_chat_event.dart';
import 'ai_chat_state.dart';

class AIChatBloc extends Bloc<AIChatEvent, AIChatState> {
  final SendAIMessage _sendAIMessage;
  final usecase.AddListActivities _addListActivities;
  final CreateScheduleFromAI _createScheduleFromAI;
  List<ChatMessageEntity> _messages = [];

  AIChatBloc({
    required SendAIMessage sendAIMessage,
    required usecase.AddListActivities addListActivities,
    required CreateScheduleFromAI createScheduleFromAI,
  })  : _sendAIMessage = sendAIMessage,
        _addListActivities = addListActivities,
        _createScheduleFromAI = createScheduleFromAI,
        super(AIChatInitial()) {
    on<SendMessage>(_onSendMessage);
    on<AddUserMessage>(_onAddUserMessage);
    on<AddAIMessage>(_onAddAIMessage);
    on<ClearChat>(_onClearChat);
    on<StartTyping>(_onStartTyping);
    on<StopTyping>(_onStopTyping);
    on<AddListActivities>(_onAddListActivities);
    on<CreateSchedule>(_onCreateSchedule);
  }

  void _onSendMessage(SendMessage event, Emitter<AIChatState> emit) async {
    // Add user message
    final userMessage = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    emit(AIChatSuccess(messages: List.from(_messages)));

    // Start typing indicator
    emit(AIChatTyping(messages: List.from(_messages)));

    try {
      // Send to AI
      final request = AIRequestEntity(message: event.message);
      final result = await _sendAIMessage(request);

      result.fold(
        (failure) {
          emit(AIChatError(message: failure.message));
        },
        (response) {
          // Add AI response message
          final aiMessage = ChatMessageEntity(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: response.aiMessage,
            isUser: false,
            timestamp: DateTime.now(),
            aiResponse: response,
          );
          _messages.add(aiMessage);
          emit(AIChatSuccess(messages: List.from(_messages)));
        },
      );
    } catch (e) {
      emit(AIChatError(message: e.toString()));
    }
  }

  void _onAddUserMessage(AddUserMessage event, Emitter<AIChatState> emit) {
    final userMessage = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    emit(AIChatSuccess(messages: List.from(_messages)));
  }

  void _onAddAIMessage(AddAIMessage event, Emitter<AIChatState> emit) {
    _messages.add(event.message);
    emit(AIChatSuccess(messages: List.from(_messages)));
  }

  void _onClearChat(ClearChat event, Emitter<AIChatState> emit) {
    _messages.clear();
    emit(AIChatInitial());
  }

  void _onStartTyping(StartTyping event, Emitter<AIChatState> emit) {
    emit(AIChatTyping(messages: List.from(_messages)));
  }

  void _onStopTyping(StopTyping event, Emitter<AIChatState> emit) {
    emit(AIChatSuccess(messages: List.from(_messages)));
  }

  void _onAddListActivities(AddListActivities event, Emitter<AIChatState> emit) async {
    print('🟣 [DEBUG] AIChatBloc._onAddListActivities called');
    print('🟣 [DEBUG] Activities count: ${event.activities.length}');
    print('🟣 [DEBUG] Emitting AIChatActivitiesLoading');
    
    emit(AIChatActivitiesLoading(messages: List.from(_messages)));

    try {
      print('🟣 [DEBUG] Calling _addListActivities use case');
      final result = await _addListActivities(event.activities);
      
      result.fold(
        (failure) {
          print('🔴 [DEBUG] AddListActivities failed: ${failure.message}');
          print('🔴 [DEBUG] Emitting AIChatActivitiesError');
          emit(AIChatActivitiesError(
            messages: List.from(_messages),
            message: failure.message,
          ));
        },
        (activities) {
          print('🟢 [DEBUG] AddListActivities succeeded: ${activities.length} activities');
          print('🟢 [DEBUG] Emitting AIChatActivitiesSuccess');
          emit(AIChatActivitiesSuccess(
            messages: List.from(_messages),
            activities: activities,
          ));
        },
      );
    } catch (e) {
      print('🔴 [DEBUG] Exception in _onAddListActivities: $e');
      print('🔴 [DEBUG] Emitting AIChatActivitiesError');
      emit(AIChatActivitiesError(
        messages: List.from(_messages),
        message: e.toString(),
      ));
    }
  }

  void _onCreateSchedule(CreateSchedule event, Emitter<AIChatState> emit) async {
    emit(AIChatScheduleLoading(messages: List.from(_messages)));

    try {
      final result = await _createScheduleFromAI(event.scheduleData);
      result.fold(
        (failure) {
          emit(AIChatScheduleError(
            messages: List.from(_messages),
            message: failure.message,
          ));
        },
        (schedule) {
          emit(AIChatScheduleSuccess(
            messages: List.from(_messages),
            schedule: schedule,
          ));
        },
      );
    } catch (e) {
      emit(AIChatScheduleError(
        messages: List.from(_messages),
        message: e.toString(),
      ));
    }
  }
}
