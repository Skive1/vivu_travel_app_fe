import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/get_schedules_by_participant_usecase.dart';
import '../../domain/usecases/get_activities_by_schedule_usecase.dart';
import '../../domain/usecases/share_schedule_usecase.dart';
import '../../domain/usecases/create_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';
import '../../domain/usecases/create_activity_usecase.dart';
import '../../domain/usecases/update_activity_usecase.dart';
import '../../domain/usecases/delete_activity_usecase.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedulesByParticipant _getSchedulesByParticipant;
  final GetActivitiesBySchedule _getActivitiesBySchedule;
  final ShareSchedule _shareSchedule;
  final CreateSchedule _createSchedule;
  final UpdateSchedule _updateSchedule;
  final CreateActivity _createActivity;
  final UpdateActivity _updateActivity;
  final DeleteActivity _deleteActivity;
  
  // Enhanced cache for schedules and activities with timestamps
  List<ScheduleEntity>? _cachedSchedules;
  final Map<String, List<ActivityEntity>> _cachedActivities = {};
  DateTime? _lastSchedulesFetch;
  final Map<String, DateTime> _lastActivitiesFetch = {};
  
  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ScheduleBloc({
    required GetSchedulesByParticipant getSchedulesByParticipant,
    required GetActivitiesBySchedule getActivitiesBySchedule,
    required ShareSchedule shareSchedule,
    required CreateSchedule createSchedule,
    required UpdateSchedule updateSchedule,
    required CreateActivity createActivity,
    required UpdateActivity updateActivity,
    required DeleteActivity deleteActivity,
  })  : _getSchedulesByParticipant = getSchedulesByParticipant,
        _getActivitiesBySchedule = getActivitiesBySchedule,
        _shareSchedule = shareSchedule,
        _createSchedule = createSchedule,
        _updateSchedule = updateSchedule,
        _createActivity = createActivity,
        _updateActivity = updateActivity,
        _deleteActivity = deleteActivity,
        super(ScheduleInitial()) {
    on<GetSchedulesByParticipantEvent>(_onGetSchedulesByParticipant);
    on<GetActivitiesByScheduleEvent>(_onGetActivitiesBySchedule);
    on<RefreshSchedulesEvent>(_onRefreshSchedules);
    on<RefreshActivitiesEvent>(_onRefreshActivities);
    on<ShareScheduleEvent>(_onShareSchedule);
    on<CreateScheduleEvent>(_onCreateSchedule);
    on<UpdateScheduleEvent>(_onUpdateSchedule);
    on<ClearCacheEvent>(_onClearCache);
    on<CreateActivityEvent>(_onCreateActivity);
    on<UpdateActivityEvent>(_onUpdateActivity);
    on<DeleteActivityEvent>(_onDeleteActivity);
  }

  void _d(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  Future<void> _onGetSchedulesByParticipant(
    GetSchedulesByParticipantEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Check cache first with timestamp validation
    if (_cachedSchedules != null && _isCacheValid(_lastSchedulesFetch)) {
      _d('🚀 ScheduleBloc: Using cached schedules (${_cachedSchedules!.length} items)');
      emit(ScheduleLoaded(schedules: _cachedSchedules!));
      return;
    }
    
    _d('🌐 ScheduleBloc: Fetching fresh schedules from server');
    emit(ScheduleLoading());
    final result = await _getSchedulesByParticipant(
      GetSchedulesByParticipantParams(participantId: event.participantId),
    );
    result.fold(
      (failure) => emit(ScheduleError(message: failure.message)),
      (schedules) {
        _cachedSchedules = schedules;
        _lastSchedulesFetch = DateTime.now();
        _d('✅ ScheduleBloc: Cached ${schedules.length} schedules');
        emit(ScheduleLoaded(schedules: schedules));
      },
    );
  }

  Future<void> _onCreateActivity(
    CreateActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(CreateActivityLoading());
    final result = await _createActivity(
      CreateActivityParams(request: event.request),
    );
    result.fold(
      (failure) => emit(CreateActivityError(message: failure.message)),
      (activity) {
        // cache update: append to cached list for its schedule
        final list = _cachedActivities[activity.scheduleId];
        if (list != null) {
          list.add(activity);
          _cachedActivities[activity.scheduleId] = List<ActivityEntity>.from(list)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }
        emit(CreateActivitySuccess(activity: activity));
        emit(ActivitiesLoaded(activities: _cachedActivities[activity.scheduleId] ?? []));
      },
    );
  }

  Future<void> _onUpdateActivity(
    UpdateActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(UpdateActivityLoading());
    final result = await _updateActivity(
      UpdateActivityParams(activityId: event.activityId, request: event.request),
    );
    result.fold(
      (failure) => emit(UpdateActivityError(message: failure.message)),
      (activity) {
        final list = _cachedActivities[activity.scheduleId];
        if (list != null) {
          final idx = list.indexWhere((a) => a.id == activity.id);
          if (idx != -1) list[idx] = activity;
          _cachedActivities[activity.scheduleId] = List<ActivityEntity>.from(list)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }
        emit(UpdateActivitySuccess(activity: activity));
        emit(ActivitiesLoaded(activities: _cachedActivities[activity.scheduleId] ?? []));
      },
    );
  }

  Future<void> _onDeleteActivity(
    DeleteActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(DeleteActivityLoading());
    final result = await _deleteActivity(event.activityId);
    result.fold(
      (failure) => emit(DeleteActivityError(message: failure.message)),
      (_) {
        final list = _cachedActivities[event.scheduleId];
        list?.removeWhere((a) => a.id == event.activityId);
        emit(DeleteActivitySuccess(scheduleId: event.scheduleId, activityId: event.activityId));
        emit(ActivitiesLoaded(activities: _cachedActivities[event.scheduleId] ?? []));
      },
    );
  }

  Future<void> _onGetActivitiesBySchedule(
    GetActivitiesByScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Check cache first with timestamp validation
    if (_cachedActivities.containsKey(event.scheduleId) && 
        _isCacheValid(_lastActivitiesFetch[event.scheduleId])) {
      _d('🚀 ScheduleBloc: Using cached activities for ${event.scheduleId} (${_cachedActivities[event.scheduleId]!.length} items)');
      emit(ActivitiesLoaded(activities: _cachedActivities[event.scheduleId]!));
      return;
    }
    
    _d('🌐 ScheduleBloc: Fetching fresh activities for ${event.scheduleId}');
    emit(ActivitiesLoading());
    final result = await _getActivitiesBySchedule(
      GetActivitiesByScheduleParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(ActivitiesError(message: failure.message)),
      (activities) {
        _cachedActivities[event.scheduleId] = activities;
        _lastActivitiesFetch[event.scheduleId] = DateTime.now();
        _d('✅ ScheduleBloc: Cached ${activities.length} activities for ${event.scheduleId}');
        emit(ActivitiesLoaded(activities: activities));
      },
    );
  }

  Future<void> _onRefreshSchedules(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _d('🔄 ScheduleBloc: Refreshing schedules for participant ${event.participantId}');
    // Clear cache and fetch fresh data
    _cachedSchedules = null;
    _cachedActivities.clear(); // Clear activities cache too
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

  Future<void> _onCreateSchedule(
    CreateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _d('📝 ScheduleBloc: _onCreateSchedule called');
    _d('📝 Request prepared');
    
    emit(CreateScheduleLoading());
    _d('📝 ScheduleBloc: Emitted CreateScheduleLoading');
    
    final result = await _createSchedule(
      CreateScheduleParams(request: event.request),
    );
    
    _d('📝 ScheduleBloc: UseCase result received');
    
    result.fold(
      (failure) {
        _d('❌ ScheduleBloc: Create failed - ${failure.message}');
        emit(CreateScheduleError(message: failure.message));
      },
      (schedule) {
        _d('✅ ScheduleBloc: Create success - ${schedule.id}');
        // Clear all cache to ensure fresh data
        _clearAllCache();
        emit(CreateScheduleSuccess(schedule: schedule));
      },
    );
  }

  Future<void> _onUpdateSchedule(
    UpdateScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _d('📝 ScheduleBloc: _onUpdateSchedule called');
    _d('📝 ScheduleId: ${event.scheduleId}');
    _d('📝 Request prepared');
    
    emit(UpdateScheduleLoading());
    _d('📝 ScheduleBloc: Emitted UpdateScheduleLoading');
    
    final result = await _updateSchedule(
      UpdateScheduleParams(
        scheduleId: event.scheduleId,
        request: event.request,
      ),
    );
    
    _d('📝 ScheduleBloc: Update UseCase result received');
    
    result.fold(
      (failure) {
        _d('❌ ScheduleBloc: Update failed - ${failure.message}');
        emit(UpdateScheduleError(message: failure.message));
      },
      (schedule) {
        _d('✅ ScheduleBloc: Update success - ${schedule.id}');
        // Clear all cache to ensure fresh data
        _clearAllCache();
        emit(UpdateScheduleSuccess(schedule: schedule));
      },
    );
  }

  // Helper method to check if cache is still valid
  bool _isCacheValid(DateTime? lastFetch) {
    if (lastFetch == null) return false;
    return DateTime.now().difference(lastFetch) < _cacheValidDuration;
  }

  // Helper method to clear all cache
  void _clearAllCache() {
    _d('🗑️ ScheduleBloc: Clearing all cache');
    _cachedSchedules = null;
    _cachedActivities.clear();
    _lastSchedulesFetch = null;
    _lastActivitiesFetch.clear();
    _d('✅ ScheduleBloc: All cache cleared');
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _clearAllCache();
  }

}
