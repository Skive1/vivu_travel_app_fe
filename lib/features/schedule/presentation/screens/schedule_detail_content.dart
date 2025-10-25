import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../domain/entities/schedule_entity.dart';
import '../widgets/schedule_detail_info.dart';
import '../widgets/schedule_qr_code.dart';
import '../widgets/edit_schedule_drawer.dart';
import '../widgets/invite_participant_modal.dart';
import '../widgets/checked_items_modal.dart';
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

    // Resolve current user id from storage if not passed in - do this first
    if (widget.currentUserId == null) {
      _resolveCurrentUserId();
    }

    // Optimistic UI: Show UI immediately with available data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Show UI first, then fetch data
      if (mounted) setState(() {});
      
      // Then fetch fresh data in background
      _fetchScheduleDetails();
    });
  }

  Future<void> _resolveCurrentUserId() async {
    try {
      final user = await UserStorage.getUserProfile();
      if (mounted) {
        setState(() => _resolvedUserId = user?.id);
        
        // If we have a cached role for this schedule, use it immediately
        if (user?.id != null) {
          final cachedRole = await UserStorage.getScheduleRole(_currentSchedule.id);
          if (cachedRole != null && cachedRole.isNotEmpty) {
            // Update the schedule with cached role for immediate UI update
            final updatedSchedule = ScheduleEntity(
              id: _currentSchedule.id,
              sharedCode: _currentSchedule.sharedCode,
              ownerId: _currentSchedule.ownerId,
              title: _currentSchedule.title,
              startLocation: _currentSchedule.startLocation,
              destination: _currentSchedule.destination,
              startDate: _currentSchedule.startDate,
              endDate: _currentSchedule.endDate,
              participantsCount: _currentSchedule.participantsCount,
              notes: _currentSchedule.notes,
              isShared: _currentSchedule.isShared,
              status: _currentSchedule.status,
              participantRole: cachedRole,
            );
            _updateScheduleData(updatedSchedule);
          }
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _fetchScheduleDetails() async {
    try {
      // Only fetch schedule details, participants will be loaded when user taps on participants count
      
      // Only fetch schedule details
      context.read<ScheduleBloc>().add(GetScheduleByIdEvent(scheduleId: _currentSchedule.id));
      
    } catch (e) {
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

  void _showCheckedItemsModal() {
    final scheduleBloc = context.read<ScheduleBloc>();
    final String role = _currentSchedule.participantRole?.toLowerCase() ?? 'viewer';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: scheduleBloc,
        child: CheckedItemsModal(
          scheduleId: _currentSchedule.id,
          userRole: role,
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
    
    // Cache the updated participantRole (non-blocking)
    if (newSchedule.participantRole != null && newSchedule.participantRole!.isNotEmpty) {
      // ignore: unawaited_futures
      UserStorage.setScheduleRole(
        scheduleId: newSchedule.id, 
        role: newSchedule.participantRole!.toLowerCase(),
      );
    }
    
    // Also cache owner role if current user is the owner
    final currentUserId = widget.currentUserId ?? _resolvedUserId;
    if (currentUserId != null && 
        currentUserId.isNotEmpty && 
        newSchedule.ownerId.isNotEmpty &&
        newSchedule.ownerId == currentUserId) {
      // ignore: unawaited_futures
      UserStorage.setScheduleRole(
        scheduleId: newSchedule.id, 
        role: 'owner',
      );
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
          _updateScheduleData(state.schedule);
          return;
        } else if (state is GetScheduleByIdError) { 
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
          // Refresh schedule detail to get updated participant count from API
          context.read<ScheduleBloc>().add(GetScheduleByIdEvent(scheduleId: _currentSchedule.id));
        } else if (state is AddParticipantByEmailSuccess) {
          // Refresh schedule detail to get updated participant count from API
          context.read<ScheduleBloc>().add(GetScheduleByIdEvent(scheduleId: _currentSchedule.id));
        } else if (state is ChangeParticipantRoleSuccess) {
          // Refresh schedule detail to get updated participant count from API
          context.read<ScheduleBloc>().add(GetScheduleByIdEvent(scheduleId: _currentSchedule.id));
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
              padding: context.responsivePadding(
                left: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ),
                right: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ),
                bottom: context.responsive(
                  verySmall: 6,
                  small: 8,
                  large: 8,
                ),
              ),
              child: BlocBuilder<ScheduleBloc, ScheduleState>(
                buildWhen: (prev, cur) =>
                    cur is GetScheduleParticipantsLoading ||
                    cur is GetScheduleParticipantsSuccess ||
                    cur is GetScheduleParticipantsError,
                builder: (context, state) {
                  // Smart role prediction: Use ownerId to predict role immediately
                  String role = 'viewer';
                  final currentUserId = widget.currentUserId ?? _resolvedUserId;
                  
                  // First priority: Check if current user is the owner
                  if (currentUserId != null && 
                      currentUserId.isNotEmpty && 
                      _currentSchedule.ownerId.isNotEmpty &&
                      _currentSchedule.ownerId == currentUserId) {
                    // Optimistic prediction: If current user is owner, show owner UI immediately
                    role = 'owner';
                  } else if (_currentSchedule.participantRole != null && 
                           _currentSchedule.participantRole!.isNotEmpty) {
                    // Use actual participantRole from API if available
                    role = _currentSchedule.participantRole!.toLowerCase();
                  } else {
                    // Fallback to viewer
                    role = 'viewer';
                  }

                  final bool canInvite = role == 'owner';
                  final bool canEditSchedule = role == 'owner' || role == 'editor';
                  final bool canShare = role == 'owner';

                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios, 
                          color: AppColors.textPrimary,
                          size: context.responsiveIconSize(
                            verySmall: 18,
                            small: 20,
                            large: 24,
                          ),
                        ),
                        onPressed: widget.onBack,
                        padding: context.responsivePadding(
                          all: context.responsive(
                            verySmall: 6,
                            small: 8,
                            large: 12,
                          ),
                        ),
                        constraints: context.responsive(
                          verySmall: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          small: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          large: BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Chi tiết lịch trình',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: context.responsiveFontSize(
                              verySmall: 14,
                              small: 16,
                              large: 20,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (canInvite)
                        IconButton(
                          icon: Icon(
                            Icons.person_add, 
                            color: AppColors.primary,
                            size: context.responsiveIconSize(
                              verySmall: 18,
                              small: 20,
                              large: 24,
                            ),
                          ),
                          onPressed: _showInviteParticipantModal,
                          tooltip: 'Mời người tham gia',
                          padding: context.responsivePadding(
                            all: context.responsive(
                              verySmall: 6,
                              small: 8,
                              large: 12,
                            ),
                          ),
                          constraints: context.responsive(
                            verySmall: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            small: BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            large: BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.checklist, 
                          color: AppColors.primary,
                          size: context.responsiveIconSize(
                            verySmall: 18,
                            small: 20,
                            large: 24,
                          ),
                        ),
                        onPressed: _showCheckedItemsModal,
                        tooltip: 'Danh sách kiểm tra',
                        padding: context.responsivePadding(
                          all: context.responsive(
                            verySmall: 6,
                            small: 8,
                            large: 12,
                          ),
                        ),
                        constraints: context.responsive(
                          verySmall: BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          small: BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          large: BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ),
                      if (canEditSchedule)
                        IconButton(
                          icon: Icon(
                            Icons.edit, 
                            color: AppColors.primary,
                            size: context.responsiveIconSize(
                              verySmall: 18,
                              small: 20,
                              large: 24,
                            ),
                          ),
                          onPressed: _showEditScheduleDrawer,
                          tooltip: 'Chỉnh sửa lịch trình',
                          padding: context.responsivePadding(
                            all: context.responsive(
                              verySmall: 6,
                              small: 8,
                              large: 12,
                            ),
                          ),
                          constraints: context.responsive(
                            verySmall: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            small: BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            large: BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
                        ),
                      if (canShare)
                        IconButton(
                          icon: _isSharing 
                            ? SizedBox(
                                width: context.responsive(
                                  verySmall: 14,
                                  small: 16,
                                  large: 20,
                                ),
                                height: context.responsive(
                                  verySmall: 14,
                                  small: 16,
                                  large: 20,
                                ),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              )
                            : Icon(
                                Icons.share, 
                                color: AppColors.primary,
                                size: context.responsiveIconSize(
                                  verySmall: 18,
                                  small: 20,
                                  large: 24,
                                ),
                              ),
                          onPressed: _isSharing ? null : _shareSchedule,
                          tooltip: 'Chia sẻ lịch trình',
                          padding: context.responsivePadding(
                            all: context.responsive(
                              verySmall: 6,
                              small: 8,
                              large: 12,
                            ),
                          ),
                          constraints: context.responsive(
                            verySmall: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            small: BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            large: BoxConstraints(
                              minWidth: 48,
                              minHeight: 48,
                            ),
                          ),
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
              padding: context.responsivePadding(
                left: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ),
                right: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ),
                top: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ),
                bottom: context.responsive(
                  verySmall: 10,
                  small: 12,
                  large: 16,
                ) + MediaQuery.of(context).padding.bottom + context.responsive(
                  verySmall: 20,
                  small: 24,
                  large: 24,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Schedule Info Card (with integrated participants)
                   ScheduleDetailInfo(
                     schedule: _currentSchedule,
                     currentUserId: widget.currentUserId ?? _resolvedUserId,
                   ),
                  SizedBox(height: context.responsiveSpacing(
                    verySmall: 10,
                    small: 12,
                    large: 16,
                  )),
                  // Share status + QR
                  Row(
                    children: [
                      Icon(
                        Icons.share,
                        size: context.responsiveIconSize(
                          verySmall: 16,
                          small: 18,
                          large: 18,
                        ),
                        color: _currentSharedCode != null && _currentSharedCode!.isNotEmpty
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: context.responsiveSpacing(
                        verySmall: 4,
                        small: 6,
                        large: 6,
                      )),
                      Text(
                        (_currentSharedCode != null && _currentSharedCode!.isNotEmpty)
                            ? 'Đã chia sẻ'
                            : 'Chưa chia sẻ',
                        style: TextStyle(
                          fontSize: context.responsiveFontSize(
                            verySmall: 12,
                            small: 14,
                            large: 14,
                          ),
                          color: _currentSharedCode != null && _currentSharedCode!.isNotEmpty
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.responsiveSpacing(
                    verySmall: 6,
                    small: 8,
                    large: 12,
                  )),
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
                          icon: Icon(
                            Icons.calendar_today,
                            size: context.responsiveIconSize(
                              verySmall: 16,
                              small: 18,
                              large: 20,
                            ),
                          ),
                          label: Text(
                            'Xem lịch trình',
                            style: TextStyle(
                              fontSize: context.responsiveFontSize(
                                verySmall: 11,
                                small: 13,
                                large: 14,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: context.responsivePadding(
                              vertical: context.responsive(
                                verySmall: 8,
                                small: 10,
                                large: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: context.responsiveSpacing(
                        verySmall: 6,
                        small: 8,
                        large: 12,
                      )),
                      if (_currentIsShared)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copySharedCode(context),
                            icon: Icon(
                              Icons.copy,
                              size: context.responsiveIconSize(
                                verySmall: 16,
                                small: 18,
                                large: 20,
                              ),
                            ),
                            label: Text(
                              'Sao chép mã',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 11,
                                  small: 13,
                                  large: 14,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              padding: context.responsivePadding(
                                vertical: context.responsive(
                                  verySmall: 8,
                                  small: 10,
                                  large: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _currentIsShared ? _shareSchedule : null,
                            icon: Icon(
                              Icons.share,
                              size: context.responsiveIconSize(
                                verySmall: 16,
                                small: 18,
                                large: 20,
                              ),
                            ),
                            label: Text(
                              'Tạo mã chia sẻ',
                              style: TextStyle(
                                fontSize: context.responsiveFontSize(
                                  verySmall: 11,
                                  small: 13,
                                  large: 14,
                                ),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _currentIsShared ? AppColors.primary : AppColors.textSecondary,
                              side: BorderSide(color: _currentIsShared ? AppColors.primary : AppColors.border),
                              padding: context.responsivePadding(
                                vertical: context.responsive(
                                  verySmall: 8,
                                  small: 10,
                                  large: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Leave section placed below the action buttons
                  _buildLeaveSectionIfApplicable(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension _LeaveSection on _ScheduleDetailContentState {
  Widget _buildLeaveSectionIfApplicable(BuildContext context) {
    final String role = (_currentSchedule.participantRole ?? '').toLowerCase();
    if (role.isEmpty || role == 'owner') return const SizedBox.shrink();

    final String? currentUserId = widget.currentUserId ?? _resolvedUserId;
    if (currentUserId == null || currentUserId.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hành động',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _confirmLeave(context, currentUserId),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.exit_to_app, size: 18, color: AppColors.error),
            label: const Text('Rời lịch', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.error)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _confirmLeave(BuildContext context, String userId) {
    final scheduleBloc = context.read<ScheduleBloc>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời lịch'),
        content: const Text('Bạn có chắc muốn rời khỏi lịch này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              scheduleBloc.add(LeaveScheduleEvent(scheduleId: _currentSchedule.id, userId: userId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Rời lịch', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
