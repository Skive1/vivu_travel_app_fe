import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/schedule_list_item.dart';
import '../widgets/create_schedule_drawer.dart';
import '../widgets/join_schedule_modal.dart';
import '../widgets/optimized_skeleton.dart';
 

class ScheduleListContent extends StatefulWidget {
  final String participantId;
  final Function(dynamic)? onScheduleTap;
  final Function(String)? onScheduleViewTap;

  const ScheduleListContent({
    Key? key,
    required this.participantId,
    this.onScheduleTap,
    this.onScheduleViewTap,
  }) : super(key: key);

  @override
  State<ScheduleListContent> createState() => _ScheduleListContentState();
}

class _ScheduleListContentState extends State<ScheduleListContent> 
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  String _statusFilter = 'all'; // all | active | completed | pending | cancelled
  Timer? _searchDebounce;
  

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  void _loadSchedules() {
    if (widget.participantId.isEmpty) {
      return;
    }
    context.read<ScheduleBloc>().add(
      GetSchedulesByParticipantEvent(participantId: widget.participantId),
    );
  }

  void _forceRefreshSchedules() {
    if (widget.participantId.isEmpty) {
      return;
    }
    // Clear cache trước khi refresh
    context.read<ScheduleBloc>().add(
      RefreshSchedulesEvent(participantId: widget.participantId),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() => _searchQuery = value.trim());
      }
    });
  }

  void _showCreateScheduleDrawer(BuildContext context) {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: CreateScheduleDrawer(
          participantId: widget.participantId,
          scheduleBloc: scheduleBloc,
          onScheduleCreated: () {
            // Clear cache và force refresh schedule list
            scheduleBloc.add(const ClearCacheEvent());
            _forceRefreshSchedules();
          },
        ),
      ),
    );
  }

  void _showJoinScheduleModal(BuildContext context) {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: const JoinScheduleModal(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return SafeArea(
      child: Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text(
                'Lịch trình của tôi',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.group_add, color: AppColors.primary),
                onPressed: () => _showJoinScheduleModal(context),
                tooltip: 'Tham gia lịch trình',
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.primary),
                onPressed: () => _showCreateScheduleDrawer(context),
                tooltip: 'Tạo lịch trình mới',
              ),
            ],
          ),
        ),
        
        // Search and filters
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tiêu đề, điểm đến...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Tất cả', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đang diễn ra', 'active'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Chờ bắt đầu', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Hoàn thành', 'completed'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Đã hủy', 'cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Main content
        Expanded(
          child: BlocListener<ScheduleBloc, ScheduleState>(
            listener: (context, state) {
              if (state is CreateScheduleSuccess) {
                // Force refresh để hiển thị lịch trình mới
                print('DEBUG: CreateScheduleSuccess - refreshing schedules');
                _forceRefreshSchedules();
              } else if (state is UpdateScheduleSuccess) {
                // Force refresh để hiển thị thay đổi
                print('DEBUG: UpdateScheduleSuccess - refreshing schedules');
                _forceRefreshSchedules();
              } else if (state is JoinScheduleSuccess) {
                // Force refresh để hiển thị lịch trình đã tham gia
                print('DEBUG: JoinScheduleSuccess - refreshing schedules');
                _forceRefreshSchedules();
              }
            },
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const ScheduleListSkeleton(itemCount: 5);
                } else if (state is ScheduleError) {
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
                            _forceRefreshSchedules();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ScheduleLoaded) {
                  // Apply client-side filtering
                  final filteredSchedules = state.schedules.where((s) {
                    final byQuery = _searchQuery.isEmpty
                        ? true
                        : (s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            s.destination.toLowerCase().contains(_searchQuery.toLowerCase()));
                    final byStatus = _statusFilter == 'all'
                        ? true
                        : s.status.toLowerCase() == _statusFilter;
                    return byQuery && byStatus;
                  }).toList();

                  if (filteredSchedules.isEmpty) {
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
                            'Chưa có lịch trình nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy tạo lịch trình đầu tiên của bạn',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateScheduleDrawer(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Tạo lịch trình mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      _forceRefreshSchedules();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = filteredSchedules[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ScheduleListItem(
                            schedule: schedule,
                            onTap: () {
                              // Gọi callback để hiển thị schedule detail trong layout
                              widget.onScheduleTap?.call(schedule);
                            },
                            onScheduleViewTap: widget.onScheduleViewTap,
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final bool isSelected = _statusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _statusFilter = value),
      selectedColor: AppColors.primary.withValues(alpha: 0.12),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      shape: StadiumBorder(
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
      ),
      backgroundColor: Colors.white,
    );
  }
}
