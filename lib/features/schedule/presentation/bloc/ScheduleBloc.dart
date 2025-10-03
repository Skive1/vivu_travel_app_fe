import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_schedules_by_participant.dart';
import '../../domain/usecases/get_activities_by_schedule.dart';
import '../../domain/usecases/share_schedule.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';
import 'ScheduleEvent.dart';
import 'ScheduleState.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedulesByParticipant _getSchedulesByParticipant;
  final GetActivitiesBySchedule _getActivitiesBySchedule;
  final ShareSchedule _shareSchedule;
  
  // Cache for schedules and activities
  List<ScheduleEntity>? _cachedSchedules;
  Map<String, List<ActivityEntity>> _cachedActivities = {};

  ScheduleBloc({
    required GetSchedulesByParticipant getSchedulesByParticipant,
    required GetActivitiesBySchedule getActivitiesBySchedule,
    required ShareSchedule shareSchedule,
  })  : _getSchedulesByParticipant = getSchedulesByParticipant,
        _getActivitiesBySchedule = getActivitiesBySchedule,
        _shareSchedule = shareSchedule,
        super(ScheduleInitial()) {
    on<GetSchedulesByParticipantEvent>(_onGetSchedulesByParticipant);
    on<GetActivitiesByScheduleEvent>(_onGetActivitiesBySchedule);
    on<RefreshSchedulesEvent>(_onRefreshSchedules);
    on<RefreshActivitiesEvent>(_onRefreshActivities);
    on<ShareScheduleEvent>(_onShareSchedule);
  }

  Future<void> _onGetSchedulesByParticipant(
    GetSchedulesByParticipantEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Check cache first
    if (_cachedSchedules != null) {
      emit(ScheduleLoaded(schedules: _cachedSchedules!));
      return;
    }
    
    emit(ScheduleLoading());
    final result = await _getSchedulesByParticipant(
      GetSchedulesByParticipantParams(participantId: event.participantId),
    );
    result.fold(
      (failure) => emit(ScheduleError(message: failure.message)),
      (schedules) {
        _cachedSchedules = schedules;
        emit(ScheduleLoaded(schedules: schedules));
      },
    );
  }

  Future<void> _onGetActivitiesBySchedule(
    GetActivitiesByScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Check cache first
    if (_cachedActivities.containsKey(event.scheduleId)) {
      emit(ActivitiesLoaded(activities: _cachedActivities[event.scheduleId]!));
      return;
    }
    
    emit(ActivitiesLoading());
    final result = await _getActivitiesBySchedule(
      GetActivitiesByScheduleParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(ActivitiesError(message: failure.message)),
      (activities) {
        _cachedActivities[event.scheduleId] = activities;
        emit(ActivitiesLoaded(activities: activities));
      },
    );
  }

  Future<void> _onRefreshSchedules(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Clear cache and fetch fresh data
    _cachedSchedules = null;
    add(GetSchedulesByParticipantEvent(participantId: event.participantId));
  }

  Future<void> _onRefreshActivities(
    RefreshActivitiesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Clear cache for this schedule and fetch fresh data
    _cachedActivities.remove(event.scheduleId);
    add(GetActivitiesByScheduleEvent(scheduleId: event.scheduleId));
  }

  Future<void> _onShareSchedule(
    ShareScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ShareScheduleLoading());
    final result = await _shareSchedule(
      ShareScheduleParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(ShareScheduleError(message: failure.message)),
      (sharedCode) => emit(ShareScheduleSuccess(sharedCode: sharedCode)),
    );
  }
}
