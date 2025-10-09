import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../home/presentation/widgets/home_bottom_nav.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../widgets/schedule_list_item.dart';
import '../widgets/create_schedule_drawer.dart';
import '../widgets/optimized_skeleton.dart';
import 'schedule_detail_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  final String participantId;

  const ScheduleListScreen({
    Key? key,
    required this.participantId,
  }) : super(key: key);

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> with AutomaticKeepAliveClientMixin {
  int _currentIndex = 2; // Schedule tab is index 2
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
    print('🔄 ScheduleListScreen: Loading schedules for participant ${widget.participantId}');
    context.read<ScheduleBloc>().add(
      GetSchedulesByParticipantEvent(participantId: widget.participantId),
    );
  }

  void _forceRefreshSchedules() {
    print('🔄 ScheduleListScreen: Force refreshing schedules');
    // Clear cache trước khi refresh
    context.read<ScheduleBloc>().add(
      RefreshSchedulesEvent(participantId: widget.participantId),
    );
    print('✅ ScheduleListScreen: Refresh event dispatched');
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to different screens based on index
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Navigate to explore screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Khám phá - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 2:
        // Already on schedule list screen
        break;
      case 3:
        // Navigate to chat screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nhắn tin - Coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
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
            print('🔄 ScheduleListScreen: Refreshing after schedule creation');
            // Clear cache và force refresh schedule list
            scheduleBloc.add(const ClearCacheEvent());
            _forceRefreshSchedules();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Lịch trình của tôi',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showCreateScheduleDrawer(context),
          ),
        ],
      ),
      body: Column(
        children: [
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
                  print('✅ ScheduleListScreen: Schedule created successfully, refreshing list');
                  // Force refresh để hiển thị lịch trình mới
                  _forceRefreshSchedules();
                } else if (state is UpdateScheduleSuccess) {
                  print('✅ ScheduleListScreen: Schedule updated successfully, refreshing list');
                  // Force refresh để hiển thị thay đổi
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
                      print('🔄 ScheduleListScreen: Retry button pressed');
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
                print('🔄 ScheduleListScreen: Pull to refresh triggered');
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
                        final scheduleBloc = context.read<ScheduleBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: scheduleBloc,
                              child: ScheduleDetailScreen(
                                schedule: schedule,
                              ),
                            ),
                          ),
                        );
                      },
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
          
          // Bottom navigation
          HomeBottomNav(
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
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
      selectedColor: AppColors.primary.withOpacity(0.12),
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
