import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/schedule_entity.dart';
import '../widgets/schedule_detail_info.dart';
import '../widgets/schedule_qr_code.dart';
import '../widgets/edit_schedule_drawer.dart';
import '../widgets/invite_participant_modal.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/user_storage.dart';

class ScheduleDetailContent extends StatefulWidget {
  final ScheduleEntity schedule;
  final Function(String)? onScheduleViewTap;
  final VoidCallback? onBack;
  final String? currentUserId;

  const ScheduleDetailContent({
    Key? key,
    required this.schedule,
    this.onScheduleViewTap,
    this.onBack,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<ScheduleDetailContent> createState() => _ScheduleDetailContentState();
}

class _ScheduleDetailContentState extends State<ScheduleDetailContent> 
    with AutomaticKeepAliveClientMixin {
  late ScheduleEntity _currentSchedule;
  String? _currentSharedCode;
  bool _isSharing = false;
  bool _currentIsShared = false;
  String? _resolvedUserId; // fetched from UserStorage when not provided

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _currentSchedule = widget.schedule;
    _currentSharedCode = widget.schedule.sharedCode;
    // If entity has isShared, capture it; fallback to sharedCode presence
    try {
      // ignore: unnecessary_null_comparison
      _currentIsShared = (widget.schedule.isShared == true);
    } catch (_) {
      _currentIsShared = (widget.schedule.sharedCode != null && widget.schedule.sharedCode!.isNotEmpty);
    }

    // Optimistic UI: Show UI immediately with available data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show UI first, then fetch data
      if (mounted) setState(() {});
      
      // Then fetch fresh data in background
      _fetchScheduleDetails();
    });

    // Resolve current user id from storage if not passed in
    if (widget.currentUserId == null) {
      () async {
        final user = await UserStorage.getUserProfile();
        // ignore: avoid_print
        print('DEBUG[Detail]: Loaded current user from storage -> ' + (user?.id ?? 'null'));
        if (mounted) setState(() => _resolvedUserId = user?.id);
      }();
    }
  }

  void _fetchScheduleDetails() async {
    try {
      // Only fetch schedule details, participants will be loaded when user taps on participants count
      print('DEBUG[Detail]: Fetching schedule details only...');
      
      // Only fetch schedule details
      context.read<ScheduleBloc>().add(GetScheduleByIdEvent(scheduleId: _currentSchedule.id));
      
    } catch (e) {
      print('DEBUG[Detail]: Error fetching schedule details: $e');
    }
  }

  void _shareSchedule() {
    if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) {
      // Nếu đã có sharedCode, chỉ hiển thị dialog
      _showShareDialog(context);
    } else {
      // Nếu chưa có sharedCode, tạo mới
      setState(() {
        _isSharing = true;
      });
      
      context.read<ScheduleBloc>().add(
        ShareScheduleEvent(scheduleId: _currentSchedule.id),
      );
    }
  }

  void _showEditScheduleDrawer() {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: EditScheduleDrawer(
          schedule: _currentSchedule,
          scheduleBloc: scheduleBloc,
          onScheduleUpdated: () {        
          },
        ),
      ),
    );
  }

  void _showInviteParticipantModal() {
    final scheduleBloc = context.read<ScheduleBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: InviteParticipantModal(
          scheduleId: _currentSchedule.id,
        ),
      ),
    );
  }

  void _updateScheduleData(ScheduleEntity newSchedule) {
    setState(() {
      _currentSchedule = newSchedule;
      _currentSharedCode = newSchedule.sharedCode;
      try {
        _currentIsShared = (newSchedule.isShared == true);
      } catch (_) {
        _currentIsShared = (_currentSharedCode != null && _currentSharedCode!.isNotEmpty);
      }
    });
    
    // Cache the updated participantRole
    if (newSchedule.participantRole != null && newSchedule.participantRole!.isNotEmpty) {
      () async {
        try {
          await UserStorage.setScheduleRole(
            scheduleId: newSchedule.id, 
            role: newSchedule.participantRole!.toLowerCase(),
          );
          // ignore: avoid_print
          print('DEBUG[Detail]: Updated cached role from schedule update: ${newSchedule.participantRole!.toLowerCase()}');
        } catch (_) {}
      }();
    }
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Mã chia sẻ của bạn:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                _currentSharedCode ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gửi mã này cho người khác để họ có thể xem lịch trình của bạn.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _copySharedCode(context);
            },
            child: const Text('Sao chép'),
          ),
        ],
      ),
    );
  }

  void _copySharedCode(BuildContext context) {
    if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _currentSharedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép mã chia sẻ'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is GetScheduleByIdSuccess) {
          // Update local schedule with full detail (includes participantRole)
          // ignore: avoid_print
          print('DEBUG[Detail]: Received schedule detail with participantRole=' + (state.schedule.participantRole?.toString() ?? 'null'));
          _updateScheduleData(state.schedule);
          return;
        } else if (state is GetScheduleByIdError) {
          // ignore: avoid_print
          print('DEBUG[Detail]: Failed to load schedule detail: ' + state.message);
        }
        if (state is ShareScheduleLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Đang tạo mã chia sẻ...'),
                ],
              ),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.primary,
            ),
          );
        } else if (state is ShareScheduleSuccess) {
          setState(() {
            _currentSharedCode = state.sharedCode;
            _isSharing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã tạo mã chia sẻ thành công'),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ShareScheduleError) {
          setState(() {
            _isSharing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi chia sẻ: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is UpdateScheduleSuccess) {
          _updateScheduleData(state.schedule);
        } else if (state is KickParticipantSuccess) {
          // Calculate active participants count from kick response
          final activeParticipantsCount = state.result.scheduleParticipantResponses
              .where((participant) => participant.status == 'Active')
              .length;
          
          print('DEBUG[DetailContent]: Calculated active participants: $activeParticipantsCount');
          print('DEBUG[DetailContent]: Total participants in response: ${state.result.scheduleParticipantResponses.length}');
          
          // Update schedule with calculated active participants count
          final updatedSchedule = ScheduleEntity(
            id: _currentSchedule.id,
            sharedCode: _currentSchedule.sharedCode,
            ownerId: _currentSchedule.ownerId,
            participantRole: _currentSchedule.participantRole,
            title: _currentSchedule.title,
            startLocation: _currentSchedule.startLocation,
            destination: _currentSchedule.destination,
            startDate: _currentSchedule.startDate,
            endDate: _currentSchedule.endDate,
            participantsCount: activeParticipantsCount, // Use calculated active count
            notes: _currentSchedule.notes,
            isShared: _currentSchedule.isShared,
            status: _currentSchedule.status,
          );
          _updateScheduleData(updatedSchedule);
        } else if (state is ScheduleLoaded) {
          // Tìm schedule hiện tại trong danh sách mới và update nếu có thay đổi
          try {
            final updatedSchedule = state.schedules.firstWhere(
              (schedule) => schedule.id == _currentSchedule.id,
            );
            
            // Update UI với data mới
            _updateScheduleData(updatedSchedule);
          } catch (e) {
            // Schedule có thể đã bị xóa hoặc không có quyền truy cập
          }
        }
      },
      child: Column(
        children: [
          // Header with SafeArea and Back button
          SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                buildWhen: (prev, cur) =>
                    cur is GetScheduleParticipantsLoading ||
                    cur is GetScheduleParticipantsSuccess ||
                    cur is GetScheduleParticipantsError,
                builder: (context, state) {
                  // Smart role prediction: Use ownerId to predict role immediately
                  String role = 'viewer';
                  final currentUserId = widget.currentUserId ?? _resolvedUserId;
                  
                  if (currentUserId != null && _currentSchedule.ownerId == currentUserId) {
                    // Optimistic prediction: If current user is owner, show owner UI immediately
                    role = 'owner';
                    print('DEBUG[DetailHeader]: Optimistic role prediction: owner (based on ownerId)');
                  } else if (_currentSchedule.participantRole != null && _currentSchedule.participantRole!.isNotEmpty) {
                    // Use actual participantRole from API if available
                    role = _currentSchedule.participantRole!.toLowerCase();
                    print('DEBUG[DetailHeader]: Using API participantRole: $role');
                  } else {
                    // Fallback to viewer
                    role = 'viewer';
                    print('DEBUG[DetailHeader]: Fallback to viewer role');
                  }

                  // DEBUG: Log role resolution
                  // ignore: avoid_print
                  print('DEBUG[DetailHeader]: participantRole from schedule = ${_currentSchedule.participantRole}, resolved role = $role');

                  final bool canInvite = role == 'owner';
                  final bool canEditSchedule = role == 'owner' || role == 'editor';
                  final bool canShare = role == 'owner';

                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                        onPressed: widget.onBack,
                      ),
                      const Text(
                        'Chi tiết lịch trình',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (canInvite)
                        IconButton(
                          icon: const Icon(Icons.person_add, color: AppColors.primary),
                          onPressed: _showInviteParticipantModal,
                          tooltip: 'Mời người tham gia',
                        ),
                      if (canEditSchedule)
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.primary),
                          onPressed: _showEditScheduleDrawer,
                          tooltip: 'Chỉnh sửa lịch trình',
                        ),
                      if (canShare)
                        IconButton(
                          icon: _isSharing 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : const Icon(Icons.share, color: AppColors.primary),
                          onPressed: _isSharing ? null : _shareSchedule,
                          tooltip: 'Chia sẻ lịch trình',
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                16 + MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Schedule Info Card (with integrated participants)
                   ScheduleDetailInfo(
                     schedule: _currentSchedule,
                     currentUserId: widget.currentUserId ?? _resolvedUserId,
                   ),
                  const SizedBox(height: 16),
                  // Share status + QR
                  Row(
                    children: [
                      Icon(
                        Icons.share,
                        size: 18,
                        color: _currentSharedCode != null && _currentSharedCode!.isNotEmpty
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        (_currentSharedCode != null && _currentSharedCode!.isNotEmpty)
                            ? 'Đã chia sẻ'
                            : 'Chưa chia sẻ',
                        style: TextStyle(
                          fontSize: 14,
                          color: _currentSharedCode != null && _currentSharedCode!.isNotEmpty
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_currentSharedCode != null && _currentSharedCode!.isNotEmpty) ...[
                    ScheduleQrCode(sharedCode: _currentSharedCode!),
                    const SizedBox(height: 24),
                  ],
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onScheduleViewTap?.call(_currentSchedule.id);
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: const Text('Xem lịch trình'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_currentIsShared)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copySharedCode(context),
                            icon: const Icon(Icons.copy),
                            label: const Text('Sao chép mã'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentIsShared ? _shareSchedule : null,
                            icon: const Icon(Icons.share),
                            label: const Text('Tạo mã chia sẻ'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _currentIsShared ? AppColors.primary : AppColors.textSecondary,
                              side: BorderSide(color: _currentIsShared ? AppColors.primary : AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
