import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../../../core/services/signalr_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final SignalRService signalRService;
  
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _connectionStateSubscription;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.signalRService,
  }) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    
    // SignalR event handlers
    on<InitializeSignalREvent>(_onInitializeSignalR);
    on<StartSignalREvent>(_onStartSignalR);
    on<StopSignalREvent>(_onStopSignalR);
    on<JoinUserGroupEvent>(_onJoinUserGroup);
    on<JoinScheduleGroupEvent>(_onJoinScheduleGroup);
    on<LeaveGroupEvent>(_onLeaveGroup);
    on<SignalRNotificationReceivedEvent>(_onSignalRNotificationReceived);
  }

  Future<void> _onGetNotifications(
    GetNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    
    try {
      final notifications = await getNotificationsUseCase();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markNotificationAsReadUseCase(event.notificationRecipientId);
      
      // Reload notifications to update the read status
      add(const GetNotificationsEvent());
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  // SignalR Event Handlers
  Future<void> _onInitializeSignalR(
    InitializeSignalREvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('🔧 NotificationBloc: _onInitializeSignalR called');
    emit(SignalRInitializing());
    
    try {
      print('🔧 NotificationBloc: Calling signalRService.initialize()');
      await signalRService.initialize();
      print('🔧 NotificationBloc: signalRService.initialize() completed');
      
      // Listen to notification stream
      _notificationSubscription?.cancel();
      _notificationSubscription = signalRService.notificationStream.listen(
        (notification) {
          if (!emit.isDone) {
            add(SignalRNotificationReceivedEvent(notification: notification));
          }
        },
      );
      
      // Listen to connection state stream
      _connectionStateSubscription?.cancel();
      _connectionStateSubscription = signalRService.connectionStateStream.listen(
        (connectionState) {
          if (!emit.isDone) {
            switch (connectionState) {
              case SignalRConnectionState.connecting:
                emit(SignalRConnecting());
                break;
              case SignalRConnectionState.connected:
                emit(SignalRConnected(
                  userId: signalRService.currentUserId,
                  joinedGroups: signalRService.joinedGroups,
                ));
                break;
              case SignalRConnectionState.disconnected:
                emit(SignalRDisconnected());
                break;
              case SignalRConnectionState.reconnecting:
                emit(SignalRReconnecting());
                break;
              case SignalRConnectionState.error:
                emit(SignalRError(message: 'Connection error'));
                break;
            }
          }
        },
      );
      
    } catch (e) {
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onStartSignalR(
    StartSignalREvent event,
    Emitter<NotificationState> emit,
  ) async {
    print('🔧 NotificationBloc: _onStartSignalR called');
    try {
      print('🔧 NotificationBloc: Calling signalRService.start()');
      await signalRService.start();
      print('🔧 NotificationBloc: signalRService.start() completed');
    } catch (e) {
      print('❌ NotificationBloc: Error starting SignalR: $e');
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onStopSignalR(
    StopSignalREvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await signalRService.stop();
      _notificationSubscription?.cancel();
      _connectionStateSubscription?.cancel();
      emit(SignalRDisconnected());
    } catch (e) {
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onJoinUserGroup(
    JoinUserGroupEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await signalRService.joinUserGroup(event.userId);
      
      // Update state with new joined groups
      if (state is SignalRConnected) {
        emit(SignalRConnected(
          userId: signalRService.currentUserId,
          joinedGroups: signalRService.joinedGroups,
        ));
      }
    } catch (e) {
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onJoinScheduleGroup(
    JoinScheduleGroupEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await signalRService.joinScheduleGroup(event.scheduleId);
      
      // Update state with new joined groups
      if (state is SignalRConnected) {
        emit(SignalRConnected(
          userId: signalRService.currentUserId,
          joinedGroups: signalRService.joinedGroups,
        ));
      }
    } catch (e) {
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onLeaveGroup(
    LeaveGroupEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await signalRService.leaveGroup(event.groupId);
      
      // Update state with new joined groups
      if (state is SignalRConnected) {
        emit(SignalRConnected(
          userId: signalRService.currentUserId,
          joinedGroups: signalRService.joinedGroups,
        ));
      }
    } catch (e) {
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onSignalRNotificationReceived(
    SignalRNotificationReceivedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(RealTimeNotificationReceived(notification: event.notification));
    
    // Reload notifications to get the latest list
    add(const GetNotificationsEvent());
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    return super.close();
  }
}
