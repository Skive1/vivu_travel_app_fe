import 'package:flutter_bloc/flutter_bloc.dart';
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
import '../../domain/usecases/join_schedule_usecase.dart';
import '../../domain/usecases/get_schedule_participants_usecase.dart';
import '../../domain/usecases/add_participant_by_email_usecase.dart';
import '../../domain/usecases/get_schedule_by_id_usecase.dart';
import '../../domain/usecases/kick_participant_usecase.dart';
import '../../domain/usecases/change_participant_role_usecase.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetSchedulesByParticipant _getSchedulesByParticipant;
  final GetScheduleById _getScheduleById;
  final GetActivitiesBySchedule _getActivitiesBySchedule;
  final ShareSchedule _shareSchedule;
  final CreateSchedule _createSchedule;
  final UpdateSchedule _updateSchedule;
  final CreateActivity _createActivity;
  final UpdateActivity _updateActivity;
  final DeleteActivity _deleteActivity;
  final JoinSchedule _joinSchedule;
  final GetScheduleParticipants _getScheduleParticipants;
  final AddParticipantByEmail _addParticipantByEmail;
  final KickParticipant _kickParticipant;
  final ChangeParticipantRole _changeParticipantRole;

  // Enhanced cache for schedules and activities with timestamps
  List<ScheduleEntity>? _cachedSchedules;
  final Map<String, List<ActivityEntity>> _cachedActivities = {};
  DateTime? _lastSchedulesFetch;
  final Map<String, DateTime> _lastActivitiesFetch = {};
  final Map<String, DateTime> _cachedActivitiesDates = {};
  
  // Cache for individual schedule details to avoid repeated API calls
  final Map<String, ScheduleEntity> _cachedScheduleDetails = {};
  final Map<String, DateTime> _lastScheduleDetailFetch = {};

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  ScheduleBloc({
    required GetSchedulesByParticipant getSchedulesByParticipant,
    required GetScheduleById getScheduleById,
    required GetActivitiesBySchedule getActivitiesBySchedule,
    required ShareSchedule shareSchedule,
    required CreateSchedule createSchedule,
    required UpdateSchedule updateSchedule,
    required CreateActivity createActivity,
    required UpdateActivity updateActivity,
    required DeleteActivity deleteActivity,
    required JoinSchedule joinSchedule,
    required GetScheduleParticipants getScheduleParticipants,
    required AddParticipantByEmail addParticipantByEmail,
    required KickParticipant kickParticipant,
    required ChangeParticipantRole changeParticipantRole,
  }) : _getSchedulesByParticipant = getSchedulesByParticipant,
       _getScheduleById = getScheduleById,
       _getActivitiesBySchedule = getActivitiesBySchedule,
       _shareSchedule = shareSchedule,
       _createSchedule = createSchedule,
       _updateSchedule = updateSchedule,
       _createActivity = createActivity,
       _updateActivity = updateActivity,
       _deleteActivity = deleteActivity,
       _joinSchedule = joinSchedule,
       _getScheduleParticipants = getScheduleParticipants,
       _addParticipantByEmail = addParticipantByEmail,
       _kickParticipant = kickParticipant,
       _changeParticipantRole = changeParticipantRole,
       super(ScheduleInitial()) {
    on<GetSchedulesByParticipantEvent>(_onGetSchedulesByParticipant);
    on<GetScheduleByIdEvent>(_onGetScheduleById);
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
    on<JoinScheduleEvent>(_onJoinSchedule);
    on<GetScheduleParticipantsEvent>(_onGetScheduleParticipants);
    on<AddParticipantByEmailEvent>(_onAddParticipantByEmail);
    on<KickParticipantEvent>(_onKickParticipant);
    on<ChangeParticipantRoleEvent>(_onChangeParticipantRole);
  }

  Future<void> _onGetScheduleById(
    GetScheduleByIdEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    print('DEBUG[Bloc]: GetScheduleByIdEvent received for scheduleId: ${event.scheduleId}');
    
    // Check cache first to avoid unnecessary API calls
    final cacheKey = event.scheduleId;
    if (_cachedScheduleDetails.containsKey(cacheKey) && 
        _isCacheValid(_lastScheduleDetailFetch[cacheKey])) {
      print('DEBUG[Bloc]: Using cached schedule detail for ${event.scheduleId}');
      emit(GetScheduleByIdSuccess(schedule: _cachedScheduleDetails[cacheKey]!));
      return;
    }
    
    emit(GetScheduleByIdLoading());
    final result = await _getScheduleById(
      GetScheduleByIdParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) {
        print('DEBUG[Bloc]: GetScheduleById failed: ${failure.message}');
        emit(GetScheduleByIdError(message: failure.message));
      },
      (schedule) {
        print('DEBUG[Bloc]: GetScheduleById success - participantRole: ${schedule.participantRole}');
        // Cache the schedule detail
        _cachedScheduleDetails[cacheKey] = schedule;
        _lastScheduleDetailFetch[cacheKey] = DateTime.now();
        emit(GetScheduleByIdSuccess(schedule: schedule));
      },
    );
  }

  Future<void> _onGetSchedulesByParticipant(
    GetSchedulesByParticipantEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Check cache first with timestamp validation
    if (_cachedSchedules != null && _isCacheValid(_lastSchedulesFetch)) {
      emit(ScheduleLoaded(schedules: _cachedSchedules!));
      return;
    }

    emit(ScheduleLoading());
    final result = await _getSchedulesByParticipant(
      GetSchedulesByParticipantParams(participantId: event.participantId),
    );
    result.fold((failure) => emit(ScheduleError(message: failure.message)), (
      schedules,
    ) {
      _cachedSchedules = schedules;
      _lastSchedulesFetch = DateTime.now();
      emit(ScheduleLoaded(schedules: schedules));
    });
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
        // cache update: append to cached list for its schedule and date
        final activityDate = activity.checkInTime;
        final cacheKey =
            '${activity.scheduleId}_${activityDate.toIso8601String().split('T')[0]}';
        final list = _cachedActivities[cacheKey];
        if (list != null) {
          list.add(activity);
          _cachedActivities[cacheKey] = List<ActivityEntity>.from(list)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }
        emit(CreateActivitySuccess(activity: activity));
        emit(ActivitiesLoaded(activities: _cachedActivities[cacheKey] ?? []));
      },
    );
  }

  Future<void> _onUpdateActivity(
    UpdateActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(UpdateActivityLoading());
    final result = await _updateActivity(
      UpdateActivityParams(
        activityId: event.activityId,
        request: event.request,
      ),
    );
    result.fold(
      (failure) => emit(UpdateActivityError(message: failure.message)),
      (activity) {
        final activityDate = activity.checkInTime;
        final cacheKey =
            '${activity.scheduleId}_${activityDate.toIso8601String().split('T')[0]}';
        final list = _cachedActivities[cacheKey];
        if (list != null) {
          final idx = list.indexWhere((a) => a.id == activity.id);
          if (idx != -1) list[idx] = activity;
          _cachedActivities[cacheKey] = List<ActivityEntity>.from(list)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
        }
        emit(UpdateActivitySuccess(activity: activity));
        
        // Trigger refresh to get fresh data from API
        add(RefreshActivitiesEvent(
          scheduleId: activity.scheduleId,
          date: activityDate,
        ));
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
        // Find and remove from all cached activities for this schedule
        _cachedActivities.forEach((key, list) {
          if (key.startsWith('${event.scheduleId}_')) {
            list.removeWhere((a) => a.id == event.activityId);
          }
        });
        emit(
          DeleteActivitySuccess(
            scheduleId: event.scheduleId,
            activityId: event.activityId,
          ),
        );
        
        // Trigger refresh to get fresh data from API
        add(RefreshActivitiesEvent(
          scheduleId: event.scheduleId,
          date: event.date,
        ));
      },
    );
  }

  Future<void> _onGetActivitiesBySchedule(
    GetActivitiesByScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Create cache key that includes both scheduleId and date
    final cacheKey =
        '${event.scheduleId}_${event.date.toIso8601String().split('T')[0]}';

    // Check cache first with timestamp validation
    if (_cachedActivities.containsKey(cacheKey) &&
        _isCacheValid(_lastActivitiesFetch[cacheKey])) {
      emit(ActivitiesLoaded(activities: _cachedActivities[cacheKey]!));
      return;
    }

    emit(ActivitiesLoading());
    final result = await _getActivitiesBySchedule(
      GetActivitiesByScheduleParams(
        scheduleId: event.scheduleId,
        date: event.date,
      ),
    );
    result.fold((failure) => emit(ActivitiesError(message: failure.message)), (
      activities,
    ) {
      _cachedActivities[cacheKey] = activities;
      _lastActivitiesFetch[cacheKey] = DateTime.now();
      _cachedActivitiesDates[cacheKey] = event.date;
      emit(ActivitiesLoaded(activities: activities));
    });
  }

  Future<void> _onRefreshSchedules(
    RefreshSchedulesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Clear cache and fetch fresh data
    _cachedSchedules = null;
    _cachedActivities.clear(); // Clear activities cache too
    add(GetSchedulesByParticipantEvent(participantId: event.participantId));
  }

  Future<void> _onRefreshActivities(
    RefreshActivitiesEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // Clear cache for this schedule and date, then fetch fresh data
    final cacheKey =
        '${event.scheduleId}_${event.date.toIso8601String().split('T')[0]}';
    _cachedActivities.remove(cacheKey);
    _lastActivitiesFetch.remove(cacheKey);
    _cachedActivitiesDates.remove(cacheKey);
    add(
      GetActivitiesByScheduleEvent(
        scheduleId: event.scheduleId,
        date: event.date,
      ),
    );
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
    emit(CreateScheduleLoading());

    final result = await _createSchedule(
      CreateScheduleParams(request: event.request),
    );

    result.fold(
      (failure) {
        emit(CreateScheduleError(message: failure.message));
      },
      (schedule) {
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
    emit(UpdateScheduleLoading());

    final result = await _updateSchedule(
      UpdateScheduleParams(
        scheduleId: event.scheduleId,
        request: event.request,
      ),
    );

    result.fold(
      (failure) {
        emit(UpdateScheduleError(message: failure.message));
      },
      (schedule) {
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
    _cachedSchedules = null;
    _cachedActivities.clear();
    _lastSchedulesFetch = null;
    _lastActivitiesFetch.clear();
    _cachedScheduleDetails.clear();
    _lastScheduleDetailFetch.clear();
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    _clearAllCache();
  }

  Future<void> _onJoinSchedule(
    JoinScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    print('DEBUG: JoinSchedule event received');
    emit(JoinScheduleLoading());
    final result = await _joinSchedule(
      JoinScheduleParams(request: event.request),
    );
    result.fold(
      (failure) {
        print('DEBUG: JoinSchedule failed: ${failure.message}');
        emit(JoinScheduleError(message: failure.message));
      },
      (response) {
        print('DEBUG: JoinSchedule success: ${response.message}');
        emit(JoinScheduleSuccess(message: response.message));
        // Clear cache to refresh schedules list
        _clearAllCache();
        print('DEBUG: Cache cleared after join success');
        // Trigger refresh schedules event if we have participant info
        // This will be handled by the UI listener
      },
    );
  }

  Future<void> _onGetScheduleParticipants(
    GetScheduleParticipantsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    // DEBUG
    // ignore: avoid_print
    print('DEBUG[Bloc]: Fetching participants for scheduleId=' + event.scheduleId);
    emit(GetScheduleParticipantsLoading());
    final result = await _getScheduleParticipants(
      GetScheduleParticipantsParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) {
        // ignore: avoid_print
        print('DEBUG[Bloc]: Get participants error=' + failure.message);
        emit(GetScheduleParticipantsError(message: failure.message));
      },
      (participants) {
        // ignore: avoid_print
        print('DEBUG[Bloc]: Participants loaded count=' + participants.length.toString());
        emit(GetScheduleParticipantsSuccess(participants: participants));
      },
    );
  }

  Future<void> _onAddParticipantByEmail(
    AddParticipantByEmailEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(AddParticipantByEmailLoading());
    final result = await _addParticipantByEmail(
      AddParticipantByEmailParams(
        scheduleId: event.scheduleId,
        request: event.request,
      ),
    );
    result.fold(
      (failure) => emit(AddParticipantByEmailError(message: failure.message)),
      (response) {
        emit(AddParticipantByEmailSuccess(message: 'Đã mời người dùng tham gia lịch trình thành công'));
        // Refresh participants list
        add(GetScheduleParticipantsEvent(scheduleId: event.scheduleId));
      },
    );
  }

  Future<void> _onKickParticipant(
    KickParticipantEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    print('DEBUG[Bloc]: Starting kick participant event');
    print('DEBUG[Bloc]: scheduleId = ${event.scheduleId}');
    print('DEBUG[Bloc]: participantId = ${event.participantId}');
    
    emit(KickParticipantLoading());
    print('DEBUG[Bloc]: Emitted KickParticipantLoading state');
    
    try {
      final result = await _kickParticipant(
        KickParticipantParams(scheduleId: event.scheduleId, participantId: event.participantId),
      );
      
      print('DEBUG[Bloc]: Kick participant use case completed');
      
      result.fold(
        (failure) {
          print('DEBUG[Bloc]: Kick participant failed with error: ${failure.message}');
          emit(KickParticipantError(message: failure.message));
        },
        (kickResult) {
          print('DEBUG[Bloc]: Kick participant successful');
          print('DEBUG[Bloc]: participantCounts = ${kickResult.participantCounts}');
          print('DEBUG[Bloc]: participants count = ${kickResult.scheduleParticipantResponses.length}');
          
          // Calculate active participants count from kick response
          final activeParticipantsCount = kickResult.scheduleParticipantResponses
              .where((participant) => participant.status == 'Active')
              .length;
          
          print('DEBUG[Bloc]: Calculated active participants: $activeParticipantsCount');
          
          emit(KickParticipantSuccess(result: kickResult));
          print('DEBUG[Bloc]: Emitted KickParticipantSuccess state');
          
          // Update participants list with new data from API response
          print('DEBUG[Bloc]: Dispatching GetScheduleParticipantsEvent to refresh UI');
          add(GetScheduleParticipantsEvent(scheduleId: event.scheduleId));
        },
      );
    } catch (e, stackTrace) {
      print('DEBUG[Bloc]: Unexpected error in _onKickParticipant');
      print('DEBUG[Bloc]: Error: $e');
      print('DEBUG[Bloc]: Stack trace: $stackTrace');
      emit(KickParticipantError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onChangeParticipantRole(
    ChangeParticipantRoleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ChangeParticipantRoleLoading());
    final result = await _changeParticipantRole(
      ChangeParticipantRoleParams(scheduleId: event.scheduleId, participantId: event.participantId),
    );
    result.fold(
      (failure) => emit(ChangeParticipantRoleError(message: failure.message)),
      (_) {
        emit(const ChangeParticipantRoleSuccess(message: "Participant's role changed"));
        // Refresh participants to update UI and cached role
        add(GetScheduleParticipantsEvent(scheduleId: event.scheduleId));
      },
    );
  }
}
