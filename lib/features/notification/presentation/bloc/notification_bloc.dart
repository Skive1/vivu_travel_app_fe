import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
  }) : super(NotificationInitial()) {
    on<GetNotificationsEvent>(_onGetNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
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
}
