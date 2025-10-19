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
import '../../domain/usecases/join_schedule_usecase.dart';
import '../../domain/usecases/get_schedule_participants_usecase.dart';
import '../../domain/usecases/add_participant_by_email_usecase.dart';
import '../../domain/usecases/get_schedule_by_id_usecase.dart';
import '../../domain/usecases/kick_participant_usecase.dart';
import '../../domain/usecases/leave_schedule_usecase.dart';
import '../../domain/usecases/change_participant_role_usecase.dart';
import '../../domain/usecases/reorder_activity_usecase.dart';
import '../../domain/usecases/get_checked_items_usecase.dart';
import '../../domain/usecases/add_checked_item_usecase.dart';
import '../../domain/usecases/toggle_checked_item_usecase.dart';
import '../../domain/usecases/delete_checked_item_usecase.dart';
import '../../domain/usecases/cancel_schedule_usecase.dart';
import '../../domain/usecases/restore_schedule_usecase.dart';
import '../../domain/usecases/checkin_activity_usecase.dart';
import '../../domain/usecases/checkout_activity_usecase.dart';
import '../../domain/usecases/get_media_by_activity_usecase.dart';
import '../../domain/usecases/upload_media_usecase.dart';

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
  final LeaveSchedule _leaveSchedule;
  final ChangeParticipantRole _changeParticipantRole;
  final ReorderActivity _reorderActivity;
  final GetCheckedItemsUseCase _getCheckedItems;
  final AddCheckedItemUseCase _addCheckedItem;
  final ToggleCheckedItemUseCase _toggleCheckedItem;
  final DeleteCheckedItemsBulkUseCase _deleteCheckedItemsBulk;
  final CancelScheduleUseCase _cancelSchedule;
  final RestoreScheduleUseCase _restoreSchedule;
  final CheckInActivityUseCase _checkInActivity;
  final CheckOutActivityUseCase _checkOutActivity;
  final GetMediaByActivityUseCase _getMediaByActivity;
  final UploadMediaUseCase _uploadMedia;

  // Enhanced cache for schedules and activities with timestamps
  List<ScheduleEntity>? _cachedSchedules;
  final Map<String, List<ActivityEntity>> _cachedActivities = {};
  DateTime? _lastSchedulesFetch;
  final Map<String, DateTime> _lastActivitiesFetch = {};
  final Map<String, DateTime> _cachedActivitiesDates = {};
  int _activitiesVersionCounter = 0;
  
  // Cache for individual schedule details to avoid repeated API calls
  final Map<String, ScheduleEntity> _cachedScheduleDetails = {};
  final Map<String, DateTime> _lastScheduleDetailFetch = {};
  final Set<String> _scheduleDetailInFlight = {};
  int _participantsVersionCounter = 0;

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
    required LeaveSchedule leaveSchedule,
    required ChangeParticipantRole changeParticipantRole,
    required ReorderActivity reorderActivity,
    required GetCheckedItemsUseCase getCheckedItems,
    required AddCheckedItemUseCase addCheckedItem,
    required ToggleCheckedItemUseCase toggleCheckedItem,
    required DeleteCheckedItemsBulkUseCase deleteCheckedItemsBulk,
    required CancelScheduleUseCase cancelSchedule,
    required RestoreScheduleUseCase restoreSchedule,
    required CheckInActivityUseCase checkInActivity,
    required CheckOutActivityUseCase checkOutActivity,
    required GetMediaByActivityUseCase getMediaByActivity,
    required UploadMediaUseCase uploadMedia,
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
       _leaveSchedule = leaveSchedule,
       _changeParticipantRole = changeParticipantRole,
       _reorderActivity = reorderActivity,
       _getCheckedItems = getCheckedItems,
       _addCheckedItem = addCheckedItem,
       _toggleCheckedItem = toggleCheckedItem,
       _deleteCheckedItemsBulk = deleteCheckedItemsBulk,
       _cancelSchedule = cancelSchedule,
       _restoreSchedule = restoreSchedule,
       _checkInActivity = checkInActivity,
       _checkOutActivity = checkOutActivity,
       _getMediaByActivity = getMediaByActivity,
       _uploadMedia = uploadMedia,
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
    on<LeaveScheduleEvent>(_onLeaveSchedule);
    on<ChangeParticipantRoleEvent>(_onChangeParticipantRole);
    on<ReorderActivityEvent>(_onReorderActivity);
    on<GetCheckedItemsEvent>(_onGetCheckedItems);
    on<AddCheckedItemEvent>(_onAddCheckedItem);
    on<ToggleCheckedItemEvent>(_onToggleCheckedItem);
    on<DeleteCheckedItemsBulkEvent>(_onDeleteCheckedItemsBulk);
    on<CancelScheduleEvent>(_onCancelSchedule);
    on<RestoreScheduleEvent>(_onRestoreSchedule);
    on<CheckInActivityEvent>(_onCheckInActivity);
    on<CheckOutActivityEvent>(_onCheckOutActivity);
    on<GetMediaByActivityEvent>(_onGetMediaByActivity);
    on<UploadMediaEvent>(_onUploadMedia);
  }

  Future<void> _onGetScheduleById(
    GetScheduleByIdEvent event,
    Emitter<ScheduleState> emit,
  ) async {    
    // Drop duplicate in-flight requests for the same schedule
    if (_scheduleDetailInFlight.contains(event.scheduleId)) {
      return;
    }

    // Check cache first to avoid unnecessary API calls
    final cacheKey = event.scheduleId;
    if (_cachedScheduleDetails.containsKey(cacheKey) && 
        _isCacheValid(_lastScheduleDetailFetch[cacheKey])) {
      emit(GetScheduleByIdSuccess(schedule: _cachedScheduleDetails[cacheKey]!));
      return;
    }
    
    emit(GetScheduleByIdLoading());
    _scheduleDetailInFlight.add(cacheKey);
    try {
      final result = await _getScheduleById(
        GetScheduleByIdParams(scheduleId: event.scheduleId),
      );
      result.fold(
        (failure) {
          emit(GetScheduleByIdError(message: failure.message));
        },
        (schedule) {
          // Cache the schedule detail
          _cachedScheduleDetails[cacheKey] = schedule;
          _lastScheduleDetailFetch[cacheKey] = DateTime.now();
          emit(GetScheduleByIdSuccess(schedule: schedule));
        },
      );
    } finally {
      _scheduleDetailInFlight.remove(cacheKey);
    }
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
        _activitiesVersionCounter++;
        emit(ActivitiesLoaded(activities: _cachedActivities[cacheKey] ?? [], version: _activitiesVersionCounter));
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
        // Avoid immediate refresh to prevent double-fetch
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
        // Avoid immediate refresh; cache already updated
      },
    );
  }

  Future<void> _onGetActivitiesBySchedule(
    GetActivitiesByScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    final t0 = DateTime.now();
    // ignore: avoid_print
    debugPrint('[TIMING][Activities] start scheduleId=${event.scheduleId} date=${event.date.toIso8601String()}');
    // Create cache key that includes both scheduleId and date
    final cacheKey =
        '${event.scheduleId}_${event.date.toIso8601String().split('T')[0]}';

    // Check cache first with timestamp validation
    if (_cachedActivities.containsKey(cacheKey) &&
        _isCacheValid(_lastActivitiesFetch[cacheKey])) {
      _activitiesVersionCounter++;
      emit(ActivitiesLoaded(activities: _cachedActivities[cacheKey]!, version: _activitiesVersionCounter));
      debugPrint('[TIMING][Activities] served from cache in ${DateTime.now().difference(t0).inMilliseconds}ms');
      return;
    }

    emit(ActivitiesLoading());
    final t1 = DateTime.now();
    debugPrint('[TIMING][Activities] emitted Loading in ${t1.difference(t0).inMilliseconds}ms');
    final result = await _getActivitiesBySchedule(
      GetActivitiesByScheduleParams(
        scheduleId: event.scheduleId,
        date: event.date,
      ),
    );
    final t2 = DateTime.now();
    debugPrint('[TIMING][Activities] usecase finished in ${t2.difference(t1).inMilliseconds}ms (total ${t2.difference(t0).inMilliseconds}ms)');
    result.fold((failure) => emit(ActivitiesError(message: failure.message)), (
      activities,
    ) {
      _cachedActivities[cacheKey] = activities;
      _lastActivitiesFetch[cacheKey] = DateTime.now();
      _cachedActivitiesDates[cacheKey] = event.date;
      _activitiesVersionCounter++;
      final t3 = DateTime.now();
      debugPrint('[TIMING][Activities] cache+prep in ${t3.difference(t2).inMilliseconds}ms (items=${activities.length})');
      emit(ActivitiesLoaded(activities: activities, version: _activitiesVersionCounter));
      final t4 = DateTime.now();
      debugPrint('[TIMING][Activities] emitted Loaded in ${t4.difference(t3).inMilliseconds}ms (total ${t4.difference(t0).inMilliseconds}ms)');
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
    emit(JoinScheduleLoading());
    final result = await _joinSchedule(
      JoinScheduleParams(request: event.request),
    );
    result.fold(
      (failure) {
        emit(JoinScheduleError(message: failure.message));
      },
      (response) {
        emit(JoinScheduleSuccess(message: response.message));
        // Clear cache to refresh schedules list
        _clearAllCache();
        // Trigger refresh schedules event if we have participant info
        // This will be handled by the UI listener
      },
    );
  }

  Future<void> _onGetScheduleParticipants(
    GetScheduleParticipantsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(GetScheduleParticipantsLoading());
    final result = await _getScheduleParticipants(
      GetScheduleParticipantsParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) {
        emit(GetScheduleParticipantsError(message: failure.message));
      },
      (participants) {
        _participantsVersionCounter++;
        emit(GetScheduleParticipantsSuccess(participants: participants, version: _participantsVersionCounter));
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
    emit(KickParticipantLoading());
    
    try {
      final result = await _kickParticipant(
        KickParticipantParams(scheduleId: event.scheduleId, participantId: event.participantId),
      );
      
      result.fold(
        (failure) {
          emit(KickParticipantError(message: failure.message));
        },
        (kickResult) {
          emit(KickParticipantSuccess(result: kickResult));
          
          // Update participants list with new data from API response
          add(GetScheduleParticipantsEvent(scheduleId: event.scheduleId));
        },
      );
    } catch (e) {

      emit(KickParticipantError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onLeaveSchedule(
    LeaveScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(LeaveScheduleLoading());
    try {
      final result = await _leaveSchedule(
        LeaveScheduleParams(scheduleId: event.scheduleId, userId: event.userId),
      );
      result.fold(
        (failure) => emit(LeaveScheduleError(message: failure.message)),
        (leaveResult) {
          emit(LeaveScheduleSuccess(result: leaveResult));
          // Refresh participants list
          add(GetScheduleParticipantsEvent(scheduleId: event.scheduleId));
        },
      );
    } catch (e) {
      emit(LeaveScheduleError(message: 'Unexpected error: $e'));
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

  Future<void> _onReorderActivity(
    ReorderActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ReorderActivityLoading());
    final result = await _reorderActivity(newIndex: event.newIndex, activityId: event.activityId);
    result.fold(
      (failure) => emit(ReorderActivityError(message: failure.message)),
      (_) {
        emit(const ReorderActivitySuccess(message: 'Update order successfully'));
        // Refresh activities for the given schedule and date
        add(RefreshActivitiesEvent(scheduleId: event.scheduleId, date: event.date));
      },
    );
  }

  Future<void> _onGetCheckedItems(
    GetCheckedItemsEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(GetCheckedItemsLoading());
    final result = await _getCheckedItems(
      GetCheckedItemsParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(GetCheckedItemsError(message: failure.message)),
      (checkedItems) => emit(GetCheckedItemsSuccess(checkedItems: checkedItems)),
    );
  }

  Future<void> _onAddCheckedItem(
    AddCheckedItemEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(AddCheckedItemLoading());
    final result = await _addCheckedItem(
      AddCheckedItemParams(request: event.request),
    );
    result.fold(
      (failure) => emit(AddCheckedItemError(message: failure.message)),
      (response) => emit(AddCheckedItemSuccess(response: response)),
    );
  }

  Future<void> _onToggleCheckedItem(
    ToggleCheckedItemEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(ToggleCheckedItemLoading());
    final result = await _toggleCheckedItem(
      ToggleCheckedItemParams(
        checkedItemId: event.checkedItemId,
        isChecked: event.isChecked,
      ),
    );
    result.fold(
      (failure) => emit(ToggleCheckedItemError(message: failure.message)),
      (checkedItem) => emit(ToggleCheckedItemSuccess(checkedItem: checkedItem)),
    );
  }

  Future<void> _onDeleteCheckedItemsBulk(
    DeleteCheckedItemsBulkEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(DeleteCheckedItemsBulkLoading());
    final result = await _deleteCheckedItemsBulk(
      DeleteCheckedItemsBulkParams(checkedItemIds: event.checkedItemIds),
    );
    result.fold(
      (failure) => emit(DeleteCheckedItemsBulkError(message: failure.message)),
      (message) => emit(DeleteCheckedItemsBulkSuccess(
        message: message,
        deletedItemIds: event.checkedItemIds,
      )),
    );
  }

  Future<void> _onCancelSchedule(
    CancelScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(CancelScheduleLoading());
    final result = await _cancelSchedule(
      CancelScheduleParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(CancelScheduleError(message: failure.message)),
      (schedule) {
        emit(CancelScheduleSuccess(schedule: schedule));
        // Clear cache to refresh schedules list
        _clearAllCache();
      },
    );
  }

  Future<void> _onRestoreSchedule(
    RestoreScheduleEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(RestoreScheduleLoading());
    final result = await _restoreSchedule(
      RestoreScheduleParams(scheduleId: event.scheduleId),
    );
    result.fold(
      (failure) => emit(RestoreScheduleError(message: failure.message)),
      (message) {
        emit(RestoreScheduleSuccess(message: message));
        // Clear cache to refresh schedules list
        _clearAllCache();
      },
    );
  }

  Future<void> _onCheckInActivity(
    CheckInActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(CheckInActivityLoading());
    final result = await _checkInActivity(
      CheckInActivityParams(request: event.request),
    );
    result.fold(
      (failure) => emit(CheckInActivityError(message: failure.message)),
      (checkIn) => emit(CheckInActivitySuccess(checkIn: checkIn)),
    );
  }

  Future<void> _onCheckOutActivity(
    CheckOutActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(CheckOutActivityLoading());
    final result = await _checkOutActivity(
      CheckOutActivityParams(request: event.request),
    );
    result.fold(
      (failure) => emit(CheckOutActivityError(message: failure.message)),
      (checkOut) => emit(CheckOutActivitySuccess(checkOut: checkOut)),
    );
  }

  Future<void> _onGetMediaByActivity(
    GetMediaByActivityEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(GetMediaByActivityLoading());
    final result = await _getMediaByActivity(
      GetMediaByActivityParams(activityId: event.activityId),
    );
    result.fold(
      (failure) => emit(GetMediaByActivityError(message: failure.message)),
      (mediaList) => emit(GetMediaByActivitySuccess(mediaList: mediaList)),
    );
  }

  Future<void> _onUploadMedia(
    UploadMediaEvent event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(UploadMediaLoading());
    final result = await _uploadMedia(
      UploadMediaParams(request: event.request),
    );
    result.fold(
      (failure) => emit(UploadMediaError(message: failure.message)),
      (media) => emit(UploadMediaSuccess(media: media)),
    );
  }
}
