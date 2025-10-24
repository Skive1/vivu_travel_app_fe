import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../../../core/services/signalr_service.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/endpoints.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final SignalRService signalRService;
  final ApiClient apiClient;
  final LocalNotificationService localNotificationService;
  
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _connectionStateSubscription;
  String? _pendingUserId; // Store user ID to join after connection

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.signalRService,
    required this.apiClient,
    required this.localNotificationService,
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
    emit(SignalRInitializing());
    
    try {
      await signalRService.initialize();
      
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
      print('🔧 NotificationBloc: Setting up connection state listener');
      _connectionStateSubscription = signalRService.connectionStateStream.listen(
        (connectionState) async {
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
                
                // Auto-join user group if we have a pending user ID
                if (_pendingUserId != null) {
                  
                  // Join user group immediately
                  try {
                    await signalRService.joinUserGroup(_pendingUserId!);
                    
                    // Also join schedule groups for this user
                    _joinScheduleGroupsForUser(_pendingUserId!);
                    
                    // Clear pending user ID
                    _pendingUserId = null;
                  } catch (e) {
                  }
                } else {
                }
                break;
              case SignalRConnectionState.disconnected:
                emit(SignalRDisconnected());
                // Clear pending user ID when disconnected
                _pendingUserId = null;
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
    try {
      print('🔄 Starting SignalR connection...');
      await signalRService.start();
      print('✅ SignalR connection started successfully');
      
      // SignalR connected successfully, now we can join user groups
      
      // Check if we already have a pending user ID (JoinUserGroupEvent came first)
      if (_pendingUserId != null && _pendingUserId!.isNotEmpty) {
        print('✅ Found existing pending userId: $_pendingUserId');
        await _joinUserAndScheduleGroups(_pendingUserId!);
        return;
      }
      
      // Wait a bit for _pendingUserId to be set (in case JoinUserGroupEvent comes after StartSignalREvent)
      int retryCount = 0;
      const maxRetries = 10; // Wait up to 5 seconds (10 * 500ms)
      
      print('⏳ Waiting for pending userId...');
      while (_pendingUserId == null && retryCount < maxRetries) {
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
        print('⏳ Waiting for userId... attempt $retryCount/$maxRetries');
      }
      
      // If we have a pending user ID, join user group and schedule groups
      if (_pendingUserId != null && _pendingUserId!.isNotEmpty) {
        print('✅ Found pending userId after waiting: $_pendingUserId');
        await _joinUserAndScheduleGroups(_pendingUserId!);
      } else {
        print('⚠️ No pending userId found after SignalR start');
      }
      
    } catch (e) {
      print('❌ Error starting SignalR: $e');
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
      // Validate userId before proceeding
      if (event.userId.isEmpty) {
        print('❌ Cannot join user group: userId is empty');
        emit(SignalRError(message: 'User ID is required'));
        return;
      }
      
      print('🔄 Joining user group for userId: ${event.userId}');
      
      // Store user ID for later joining if SignalR is not connected yet
      _pendingUserId = event.userId;
      
      // If SignalR is already connected, join immediately
      if (signalRService.isConnected) {
        print('✅ SignalR is connected, joining user group immediately');
        await _joinUserAndScheduleGroups(event.userId);
        
        // Update state with new joined groups
        if (state is SignalRConnected) {
          emit(SignalRConnected(
            userId: signalRService.currentUserId,
            joinedGroups: signalRService.joinedGroups,
          ));
        }
      } else {
        print('⏳ SignalR not connected yet, storing userId for later joining');
      }
    } catch (e) {
      print('❌ Error joining user group: $e');
      emit(SignalRError(message: e.toString()));
    }
  }

  Future<void> _onJoinScheduleGroup(
    JoinScheduleGroupEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      // Validate scheduleId before proceeding
      if (event.scheduleId.isEmpty) {
        print('❌ Cannot join schedule group: scheduleId is empty');
        emit(SignalRError(message: 'Schedule ID is required'));
        return;
      }
      
      // Check if SignalR is ready for operations
      if (!signalRService.isReady) {
        print('❌ Cannot join schedule group: SignalR is not ready (connected: ${signalRService.isConnected}, state: ${signalRService.getConnectionDiagnostics()['connectionState']})');
        emit(SignalRError(message: 'SignalR is not ready for operations'));
        return;
      }
      
      print('🔄 Joining schedule group: ${event.scheduleId}');
      
      await signalRService.joinScheduleGroup(event.scheduleId);
      print('✅ Successfully joined schedule group: ${event.scheduleId}');
      
      // Update state with new joined groups
      if (state is SignalRConnected) {
        emit(SignalRConnected(
          userId: signalRService.currentUserId,
          joinedGroups: signalRService.joinedGroups,
        ));
      }
    } catch (e) {
      print('❌ Error joining schedule group: $e');
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
    
    // Show popup notification
    try {
      final notification = event.notification;
      
      // Extract notification data based on backend format
      final title = notification['title'] ?? 'Thông báo mới';
      final message = notification['message'] ?? 'Bạn có thông báo mới';
      final scheduleName = notification['scheduleName'] ?? '';
      final senderName = notification['senderName'] ?? '';
      final type = notification['type'] ?? '';
      final scheduleId = notification['scheduleID'] ?? notification['scheduleId'];
      
      
      if (type == 'ScheduleUpdated' && scheduleName.isNotEmpty) {
        // Show schedule update notification
        await localNotificationService.showScheduleUpdateNotification(
          scheduleName: scheduleName,
          message: message,
          senderName: senderName,
          scheduleId: scheduleId,
        );
      } else {
        // Show general notification
        await localNotificationService.showGeneralNotification(
          title: title,
          message: message,
          type: type,
        );
      }
      
    } catch (e) {
      // Fallback: show basic notification
      await localNotificationService.showGeneralNotification(
        title: 'Thông báo mới',
        message: 'Bạn có thông báo mới từ ứng dụng',
      );
    }
    
    emit(RealTimeNotificationReceived(notification: event.notification));
    
    // Reload notifications to get the latest list
    add(const GetNotificationsEvent());
  }

  /// Join user group and schedule groups for a user
  Future<void> _joinUserAndScheduleGroups(String userId) async {
    try {
      // Validate userId before proceeding
      if (userId.isEmpty) {
        print('❌ Cannot join groups: userId is empty');
        return;
      }
      
      print('🔄 Joining user and schedule groups for userId: $userId');
      
      // Join user group first
      await signalRService.joinUserGroup(userId);
      print('✅ Successfully joined user group: $userId');
      
      // Then load and join schedule groups for this user
      await _joinScheduleGroupsForUser(userId);
      
      // Clear pending user ID
      _pendingUserId = null;
      print('✅ Completed joining user and schedule groups');
      
    } catch (e) {
      print('❌ Error joining user and schedule groups: $e');
    }
  }

  /// Join schedule groups for a user based on their schedules
  Future<void> _joinScheduleGroupsForUser(String userId) async {
    try {
      // Validate userId before making API call
      if (userId.isEmpty) {
        print('❌ Cannot join schedule groups: userId is empty');
        return;
      }
      
      print('🔄 Loading schedules for user: $userId');
      
      // Get user's schedules from API with retry mechanism
      int retryCount = 0;
      const maxRetries = 3;
      dynamic response;
      
      while (retryCount < maxRetries) {
        try {
          response = await apiClient.get('${Endpoints.getSchedulesByParticipant}/$userId');
          break; // Success, exit retry loop
        } catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            print('❌ Failed to load schedules after $maxRetries attempts: $e');
            return;
          }
          print('⚠️ Retry $retryCount/$maxRetries loading schedules: $e');
          await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
        }
      }
      
      if (response.statusCode == 200) {
        final List<dynamic> schedules = response.data;
        print('✅ Loaded ${schedules.length} schedules for user $userId');
        
        // Wait for SignalR to be ready before joining groups
        await _waitForSignalRReady();
        
        // Validate and join each schedule group sequentially
        int joinedCount = 0;
        int failedCount = 0;
        
        for (final schedule in schedules) {
          if (schedule is Map<String, dynamic> && schedule['id'] != null) {
            final scheduleId = schedule['id'].toString();
            if (scheduleId.isNotEmpty) {
              try {
                print('🔄 Joining schedule group: $scheduleId');
                await signalRService.joinScheduleGroup(scheduleId);
                joinedCount++;
                print('✅ Successfully joined schedule group: $scheduleId');
                
                // Verify the schedule ID was added to joinedGroups
                if (signalRService.joinedGroups.contains(scheduleId)) {
                  print('✅ Schedule group $scheduleId confirmed in joinedGroups');
                } else {
                  print('⚠️ Schedule group $scheduleId not found in joinedGroups after joining');
                }
                
                // Small delay between joins
                await Future.delayed(const Duration(milliseconds: 50));
              } catch (e) {
                failedCount++;
                print('❌ Error joining schedule group $scheduleId: $e');
              }
            } else {
              print('⚠️ Skipping empty scheduleId');
            }
          } else {
            print('⚠️ Skipping invalid schedule data: $schedule');
          }
        }
        
        print('✅ Successfully joined $joinedCount schedule groups, $failedCount failed');
        print('📋 Final joined groups: ${signalRService.joinedGroups}');
      } else {
        print('❌ Failed to load schedules: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error joining schedule groups: $e');
    }
  }
  
  /// Wait for SignalR to be ready for operations
  Future<void> _waitForSignalRReady() async {
    const maxWaitTime = Duration(seconds: 10);
    const checkInterval = Duration(milliseconds: 200);
    final startTime = DateTime.now();
    
    print('⏳ Waiting for SignalR to be ready...');
    
    while (DateTime.now().difference(startTime) < maxWaitTime) {
      if (signalRService.isReady) {
        print('✅ SignalR is ready for operations');
        return;
      }
      
      final diagnostics = signalRService.getConnectionDiagnostics();
      print('🔍 SignalR status: connected=${signalRService.isConnected}, state=${diagnostics['connectionState']}, ready=${signalRService.isReady}');
      
      await Future.delayed(checkInterval);
    }
    
    final finalDiagnostics = signalRService.getConnectionDiagnostics();
    print('❌ SignalR ready timeout. Final status: $finalDiagnostics');
    throw Exception('SignalR is not ready for operations after timeout');
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _pendingUserId = null; // Clear pending user ID
    return super.close();
  }

}
