import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/activity_entity.dart';
import 'activity_timeline_item.dart';
import 'optimized_skeleton.dart';
import 'add_activity_form.dart';
import '../../../../core/utils/user_storage.dart';
 

class ScheduleList extends StatefulWidget {
  final DateTime selectedDate;
  final String? scheduleId;
  final String? currentUserId;

  const ScheduleList({super.key, required this.selectedDate, this.scheduleId, this.currentUserId});

  @override
  State<ScheduleList> createState() => _ScheduleListState();
}

class _ScheduleListState extends State<ScheduleList> {
  String? _cachedRole; // owner | editor | viewer
  List<ActivityEntity> _activitiesLocal = [];
  bool _dragMode = false;

  @override
  void initState() {
    super.initState();
    // Load activities for initial date
    _loadActivitiesForDate(widget.selectedDate);
    _loadCachedRole();
  }

  @override
  void didUpdateWidget(ScheduleList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if selectedDate has changed
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadActivitiesForDate(widget.selectedDate);
    }
    if (oldWidget.scheduleId != widget.scheduleId) {
      _loadCachedRole();
    }
  }

  void _loadActivitiesForDate(DateTime date) {
    if (widget.scheduleId != null && widget.scheduleId!.isNotEmpty) {
      context.read<ScheduleBloc>().add(
        GetActivitiesByScheduleEvent(
          scheduleId: widget.scheduleId!,
          date: date,
        ),
      );
    }
  }

  void _loadCachedRole() async {
    if (widget.scheduleId == null) return;
    final role = await UserStorage.getScheduleRole(widget.scheduleId!);
    // ignore: avoid_print
    print('DEBUG[ScheduleList]: Cached role read -> ' + (role ?? 'null'));
    if (!mounted) return;
    if (role != null && role.isNotEmpty) {
      setState(() => _cachedRole = role.toLowerCase());
    }
  }

  // merged into existing didUpdateWidget above

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is KickParticipantSuccess) {
          // Calculate active participants count from kick response
          final activeParticipantsCount = state.result.scheduleParticipantResponses
              .where((participant) => participant.status == 'Active')
              .length;
          
          print('DEBUG[ScheduleList]: Kick participant success');
          print('DEBUG[ScheduleList]: Calculated active participants: $activeParticipantsCount');
          print('DEBUG[ScheduleList]: Total participants in response: ${state.result.scheduleParticipantResponses.length}');
          print('DEBUG[ScheduleList]: API participantCounts: ${state.result.participantCounts}');
          
          // The schedule list will be refreshed automatically by the parent
        }
        
      },
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        // DEBUG
        // ignore: avoid_print
        print('DEBUG[ScheduleList]: state=' + state.runtimeType.toString() + ', scheduleId=' + (widget.scheduleId ?? 'null') + ', selectedDate=' + widget.selectedDate.toIso8601String());
        if (state is ActivitiesLoading) {
          return const ActivityListSkeleton(itemCount: 3);
        } else if (state is ActivitiesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (widget.scheduleId != null) {
                      context.read<ScheduleBloc>().add(
                        RefreshActivitiesEvent(
                          scheduleId: widget.scheduleId!,
                          date: widget.selectedDate,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        } else if (state is ActivitiesLoaded) {
          final activities = _filterActivitiesByDate(
            state.activities,
            widget.selectedDate,
          );

          if (activities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getEmptyStateTitle(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyStateMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  if (widget.scheduleId != null && _canCreateActivity(context))
                    ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            child: BlocProvider.value(
                              value: context.read<ScheduleBloc>(),
                              child: AddActivityForm(
                                scheduleId: widget.scheduleId!,
                                initialDate: widget.selectedDate,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm hoạt động'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          // NOTE: Sorting should be done upstream (Bloc) to avoid per-build sorting costs.

          // Keep a local copy for UI reordering UX
          if (_activitiesLocal.isEmpty || _activitiesLocal.length != activities.length || !_isSameOrder(_activitiesLocal, activities)) {
            _activitiesLocal = List<ActivityEntity>.from(activities);
          }

          final role = _getRole(context);
          final bool canEditOrder = role == 'owner' || role == 'editor';

          return RefreshIndicator(
            onRefresh: () async {
              if (widget.scheduleId != null) {
                context.read<ScheduleBloc>().add(
                  RefreshActivitiesEvent(
                                scheduleId: widget.scheduleId!,
                    date: widget.selectedDate,
                  ),
                );
              }
            },
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: canEditOrder
                      ? ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) => Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(16),
                        child: child,
                      ),
                      onReorder: (oldIndex, newIndex) {
                        if (!_dragMode) {
                          return; // drag disabled unless toggled on
                        }
                        setState(() {
                          // Convert to target index for swap behavior
                          int targetIndex = newIndex;
                          if (newIndex > oldIndex) targetIndex = newIndex - 1;
                          if (oldIndex == targetIndex) return;

                          // Swap two items locally and also swap their orderIndex for immediate UI update
                          final a = _activitiesLocal[oldIndex];
                          final b = _activitiesLocal[targetIndex];
                          _activitiesLocal[oldIndex] = _withOrderIndex(b, a.orderIndex);
                          _activitiesLocal[targetIndex] = _withOrderIndex(a, b.orderIndex);

                          // Fire two API calls to set correct positions
                          if (widget.scheduleId != null) {
                            final moved = _activitiesLocal[targetIndex];
                            final swapped = _activitiesLocal[oldIndex];
                            // Send swapped orderIndex values to backend
                            final newIndexForMoved = moved.orderIndex;
                            final newIndexForSwapped = swapped.orderIndex;
                            context.read<ScheduleBloc>().add(
                              ReorderActivityEvent(
                                activityId: moved.id,
                                newIndex: newIndexForMoved,
                                scheduleId: widget.scheduleId!,
                                date: widget.selectedDate,
                              ),
                            );
                            context.read<ScheduleBloc>().add(
                              ReorderActivityEvent(
                                activityId: swapped.id,
                                newIndex: newIndexForSwapped,
                                scheduleId: widget.scheduleId!,
                                date: widget.selectedDate,
                              ),
                            );
                          }
                        });
                      },
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: _activitiesLocal.length + ((widget.scheduleId != null && _canCreateActivity(context)) ? 1 : 0),
                      itemBuilder: (context, index) {
                        final isAppendButton =
                            (widget.scheduleId != null && _canCreateActivity(context)) && index == _activitiesLocal.length;
                        if (isAppendButton) {
                          return Center(
                            key: const ValueKey('append_button'),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: BlocProvider.value(
                                          value: context.read<ScheduleBloc>(),
                                          child: AddActivityForm(
                                            scheduleId: widget.scheduleId!,
                                            initialDate: widget.selectedDate,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: const Icon(Icons.add, size: 24),
                                ),
                              ),
                            ),
                          );
                        }

                        final activity = _activitiesLocal[index];
                        final isLast = index == _activitiesLocal.length - 1;
                        final bool canEdit = canEditOrder;
                        final bool canDelete = role == 'owner';
                        final item = ActivityTimelineItem(
                          key: ValueKey<int>(activity.id),
                          activity: activity,
                          isLast: isLast,
                          selectedDate: widget.selectedDate,
                          canEdit: canEdit,
                          canDelete: canDelete,
                        );
                        if (_dragMode) {
                          return ReorderableDragStartListener(
                            key: ValueKey<int>(activity.id),
                            index: index,
                            child: item,
                          );
                        } else {
                          return item;
                        }
                      },
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: activities.length + ((widget.scheduleId != null && _canCreateActivity(context)) ? 1 : 0),
                      itemBuilder: (context, index) {
                        final isAppendButton =
                            (widget.scheduleId != null && _canCreateActivity(context)) && index == activities.length;
                        if (isAppendButton) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        child: BlocProvider.value(
                                          value: context.read<ScheduleBloc>(),
                                          child: AddActivityForm(
                                            scheduleId: widget.scheduleId!,
                                            initialDate: widget.selectedDate,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(0),
                                  ),
                                  child: const Icon(Icons.add, size: 24),
                                ),
                              ),
                            ),
                          );
                        }

                        final activity = activities[index];
                        final isLast = index == activities.length - 1;
                        final bool canEdit = false;
                        final bool canDelete = false;
                        return ActivityTimelineItem(
                          key: ValueKey<int>(activity.id),
                          activity: activity,
                          isLast: isLast,
                          selectedDate: widget.selectedDate,
                          canEdit: canEdit,
                          canDelete: canDelete,
                        );
                      },
                    ),
                ),
                
                if (canEditOrder && _activitiesLocal.isNotEmpty)
                  Positioned(
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    child: FloatingActionButton.extended(
                      heroTag: 'toggle-drag',
                      backgroundColor: _dragMode ? Colors.redAccent : AppColors.primary,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        setState(() {
                          _dragMode = !_dragMode;
                        });
                      },
                      icon: Icon(_dragMode ? Icons.close : Icons.drag_indicator),
                      label: Text(_dragMode ? 'Xong' : 'Sắp xếp'),
                    ),
                  ),
              ],
            ),
          );
        }

        // If no scheduleId provided, show empty state
        if (widget.scheduleId == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Chọn một lịch trình',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Để xem các hoạt động trong lịch trình',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (widget.scheduleId != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: BlocProvider.value(
                            value: context.read<ScheduleBloc>(),
                            child: AddActivityForm(
                              scheduleId: widget.scheduleId!,
                                      initialDate: widget.selectedDate,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hoạt động'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
      ),
    );
  }

  String _getRole(BuildContext context) {
    // Use cached role immediately if available (fast path)
    if (_cachedRole != null) return _cachedRole!;
    
    // Fallback to viewer if no cached role
    return 'viewer';
  }

  bool _canCreateActivity(BuildContext context) {
    final role = _getRole(context);
    return role == 'owner';
  }

  bool _isSameOrder(List<ActivityEntity> a, List<ActivityEntity> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  ActivityEntity _withOrderIndex(ActivityEntity a, int newOrderIndex) {
    return ActivityEntity(
      id: a.id,
      placeName: a.placeName,
      location: a.location,
      description: a.description,
      checkInTime: a.checkInTime,
      checkOutTime: a.checkOutTime,
      orderIndex: newOrderIndex,
      isDeleted: a.isDeleted,
      scheduleId: a.scheduleId,
    );
  }

  List<ActivityEntity> _filterActivitiesByDate(
    List<ActivityEntity> activities,
    DateTime selectedDate,
  ) {
    return activities.where((activity) {
      final activityDate = DateTime(
        activity.checkInTime.year,
        activity.checkInTime.month,
        activity.checkInTime.day,
      );
      final selected = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
      );
      return activityDate.isAtSameMomentAs(selected);
    }).toList();
  }

  String _getEmptyStateTitle() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (selected.isAtSameMomentAs(today)) {
      return 'Hôm nay không có hoạt động';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Ngày mai không có hoạt động';
    } else if (selected.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Hôm qua không có hoạt động';
    } else {
      return 'Không có hoạt động';
    }
  }

  String _getEmptyStateMessage() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );

    if (selected.isAtSameMomentAs(today)) {
      return 'Hãy thêm hoạt động cho ngày hôm nay';
    } else if (selected.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return 'Hãy thêm hoạt động cho ngày mai';
    } else if (selected.isAtSameMomentAs(
      today.subtract(const Duration(days: 1)),
    )) {
      return 'Hôm qua không có hoạt động nào được lên lịch';
    } else {
      return 'Hãy thêm hoạt động cho ngày này';
    }
  }
}
