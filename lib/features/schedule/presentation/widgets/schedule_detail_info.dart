import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/participant_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../../../../core/utils/user_storage.dart';
import '../../../../core/utils/dialog_utils.dart';

class ScheduleDetailInfo extends StatefulWidget {
  final ScheduleEntity schedule;
  final String? currentUserId;

  const ScheduleDetailInfo({
    Key? key,
    required this.schedule,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<ScheduleDetailInfo> createState() => _ScheduleDetailInfoState();
}

class _ScheduleDetailInfoState extends State<ScheduleDetailInfo> {
  bool _isParticipantsExpanded = false;
  late ScheduleEntity _currentSchedule;

  @override
  void initState() {
    super.initState();
    _currentSchedule = widget.schedule;
    // Load participants when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleBloc>().add(
        GetScheduleParticipantsEvent(scheduleId: _currentSchedule.id),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScheduleBloc, ScheduleState>(
      listener: (context, state) async {
        if (state is KickParticipantLoading) {
          // Show loading dialog when kicking participant
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang chặn thành viên...'),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is ChangeParticipantRoleLoading) {
          // Optional: keep subtle feedback or a loading dialog if desired
        } else if (state is KickParticipantError) {
          print('DEBUG[UI]: Received KickParticipantError state');
          print('DEBUG[UI]: Error message: ${state.message}');
          
          // Close loading dialog first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          await DialogUtils.showErrorDialog(
            context: context,
            title: 'Chặn thành viên thất bại',
            message: state.message,
            useRootNavigator: true,
          );
          print('DEBUG[UI]: Error dialog shown');
        } else if (state is ChangeParticipantRoleError) {
          await DialogUtils.showErrorDialog(
            context: context,
            title: 'Thay đổi quyền thất bại',
            message: state.message,
            useRootNavigator: true,
          );
        } else if (state is ChangeParticipantRoleSuccess) {
          await DialogUtils.showSuccessDialog(
            context: context,
            title: 'Thay đổi quyền thành công',
            message: 'Quyền của thành viên đã được thay đổi.',
            useRootNavigator: true,
          );
        } else if (state is KickParticipantSuccess) {
          print('DEBUG[UI]: Received KickParticipantSuccess state');
          print('DEBUG[UI]: participantCounts = ${state.result.participantCounts}');
          print('DEBUG[UI]: participants count = ${state.result.scheduleParticipantResponses.length}');
          
          // Close loading dialog first
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Calculate active participants count from kick response
          final activeParticipantsCount = state.result.scheduleParticipantResponses
              .where((participant) => participant.status == 'Active')
              .length;
          
          print('DEBUG[UI]: Calculated active participants: $activeParticipantsCount');
          print('DEBUG[UI]: Total participants in response: ${state.result.scheduleParticipantResponses.length}');
          
          await DialogUtils.showSuccessDialog(
            context: context,
            title: 'Đã chặn thành viên',
            message: 'Thành viên đã bị chặn khỏi lịch trình.',
            useRootNavigator: true,
          );
          print('DEBUG[UI]: Success dialog shown');
        } else if (state is GetScheduleParticipantsSuccess) {
          // Participants loaded successfully - update schedule with active participants count
          final activeParticipantsCount = state.participants
              .where((participant) => participant.status.toLowerCase() == 'active')
              .length;
          
          print('DEBUG[UI]: GetScheduleParticipantsSuccess - Active participants: $activeParticipantsCount');
          
          // Update schedule with new active participants count
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
            participantsCount: activeParticipantsCount, // Update with actual active count
            notes: _currentSchedule.notes,
            isShared: _currentSchedule.isShared,
            status: _currentSchedule.status,
          );
          
          // Update the current schedule
          setState(() {
            _currentSchedule = updatedSchedule;
          });
        }
        
        // Store participant role from schedule if available
        if (_currentSchedule.participantRole != null && _currentSchedule.participantRole!.isNotEmpty) {
          try {
            await UserStorage.setScheduleRole(
              scheduleId: _currentSchedule.id, 
              role: _currentSchedule.participantRole!.toLowerCase(),
            );
          } catch (_) {}
        }
      },
      child: BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        List<ParticipantEntity> participants = [];
        bool isLoadingParticipants = false;
        String? participantsError;

        if (state is GetScheduleParticipantsLoading) {
          isLoadingParticipants = true;
        } else if (state is GetScheduleParticipantsSuccess) {
          participants = state.participants;
        } else if (state is GetScheduleParticipantsError) {
          participantsError = state.message;
        }

        // Split participants by status for UI control
        final List<ParticipantEntity> bannedParticipants = participants
            .where((p) => p.status.toLowerCase() == 'banned')
            .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status
          Row(
            children: [
              Expanded(
                child: Text(
                      _currentSchedule.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                      color: _getStatusColor(_currentSchedule.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                      _getStatusText(_currentSchedule.status),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                        color: _getStatusColor(_currentSchedule.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Location
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'Địa điểm',
                content: '${_currentSchedule.startLocation} → ${_currentSchedule.destination}',
          ),
          const SizedBox(height: 16),
          // Date range
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Thời gian',
                content: '${_formatDateTime(_currentSchedule.startDate)} - ${_formatDateTime(_currentSchedule.endDate)}',
          ),
          const SizedBox(height: 16),
              // Participants - Active only by default
              _buildParticipantsRow(
                participants,
                isLoadingParticipants,
                participantsError,
                bannedParticipantsCount: bannedParticipants.length,
                bannedParticipants: bannedParticipants,
                onViewBannedTap: bannedParticipants.isEmpty
                    ? null
                    : () => _showBannedParticipantsModal(bannedParticipants),
          ),
          const SizedBox(height: 16),       
          // Notes (if available)
              if (_currentSchedule.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.note_outlined,
              title: 'Ghi chú',
                  content: _currentSchedule.notes,
                ),
              ],
            ],
          ),
        );
      },
    ),
  );
  }

  Widget _buildParticipantsRow(
    List<ParticipantEntity> participants,
    bool isLoading,
    String? error, {
    int bannedParticipantsCount = 0,
    VoidCallback? onViewBannedTap,
    List<ParticipantEntity>? bannedParticipants,
  }) {
    // Split participants by status for UI control
    final List<ParticipantEntity> activeParticipants = participants
        .where((p) => p.status.toLowerCase() == 'active')
        .toList();
    final List<ParticipantEntity> bannedParticipantsList = bannedParticipants ?? [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.people_outline,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Số người tham gia',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              // Always show participantsCount first, then load details on tap
              InkWell(
                onTap: () {
                  // Load participants details when tapped
                  if (participants.isEmpty && !isLoading) {
                    context.read<ScheduleBloc>().add(GetScheduleParticipantsEvent(scheduleId: _currentSchedule.id));
                  }
                  setState(() {
                    _isParticipantsExpanded = !_isParticipantsExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Text(
                      '${activeParticipants.length} người',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isParticipantsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Show loading indicator when fetching participants
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              // Show error if failed to load
              else if (error != null)
                const Text(
                  'Lỗi tải dữ liệu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                )
              // Show participants details when expanded
              else if (_isParticipantsExpanded && participants.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active participants section
                      if (activeParticipants.isNotEmpty) ...[
                        Text(
                          'Thành viên hoạt động (${activeParticipants.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...activeParticipants.map((p) => _buildParticipantItem(p, widget.currentUserId, _currentSchedule.id)),
                        if (bannedParticipantsList.isNotEmpty) const SizedBox(height: 12),
                      ],
                      
                      // Banned participants section
                      if (bannedParticipantsList.isNotEmpty) ...[
                        Row(
                          children: [
                            Text(
                              'Thành viên bị chặn (${bannedParticipantsList.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.error,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: onViewBannedTap,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.visibility, size: 16),
                              label: const Text('Xem', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...bannedParticipantsList.map((p) => _buildParticipantItem(p, widget.currentUserId, _currentSchedule.id)),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showBannedParticipantsModal(List<ParticipantEntity> banned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.block, color: AppColors.error, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Người dùng bị chặn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...banned.map((p) => _buildBannedItem(p)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantItem(ParticipantEntity p, String? currentUserId, String scheduleId) {
    final isOwner = currentUserId != null && p.userId == currentUserId;
    final isBanned = p.status.toLowerCase() == 'banned';
    final canManage = !isOwner && !isBanned; // Owner can manage others but not themselves, and not banned users
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.textSecondary,
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(p.role).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.role,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getRoleColor(p.role)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getParticipantStatusColor(p.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getParticipantStatusColor(p.status)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons for owner (only for active participants)
          if (canManage) ...[
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'kick') {
                  _showKickConfirmation(p, scheduleId);
                } else if (value == 'change_role') {
                  _showChangeRoleModal(p, scheduleId);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'kick',
                  child: Row(
                    children: [
                      Icon(Icons.block, color: AppColors.error, size: 16),
                      SizedBox(width: 8),
                      Text('Chặn thành viên'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'change_role',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: AppColors.primary, size: 16),
                      SizedBox(width: 8),
                      Text('Thay đổi quyền'),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  void _showKickConfirmation(ParticipantEntity participant, String scheduleId) {
    print('DEBUG[UI]: Showing kick confirmation dialog');
    print('DEBUG[UI]: participant.name = ${participant.name}');
    print('DEBUG[UI]: participant.userId = ${participant.userId}');
    print('DEBUG[UI]: scheduleId = $scheduleId');
    
    // Capture ScheduleBloc before showing dialog
    final scheduleBloc = context.read<ScheduleBloc>();
    print('DEBUG[UI]: ScheduleBloc captured successfully');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chặn thành viên'),
        content: Text('Bạn có chắc chắn muốn chặn ${participant.name}?'),
        actions: [
          TextButton(
            onPressed: () {
              print('DEBUG[UI]: User cancelled kick action');
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              print('DEBUG[UI]: User confirmed kick action');
              print('DEBUG[UI]: Dispatching KickParticipantEvent');
              print('DEBUG[UI]: scheduleId = $scheduleId');
              print('DEBUG[UI]: participantId = ${participant.userId}');
              
              Navigator.pop(context);
              scheduleBloc.add(KickParticipantEvent(
                scheduleId: scheduleId,
                participantId: participant.userId,
              ));
              print('DEBUG[UI]: KickParticipantEvent dispatched successfully');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Chặn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleModal(ParticipantEntity participant, String scheduleId) {
    // Toggle role: viewer -> editor, editor -> viewer
    context.read<ScheduleBloc>().add(ChangeParticipantRoleEvent(
      scheduleId: scheduleId,
      participantId: participant.userId,
    ));
  }

  Widget _buildBannedItem(ParticipantEntity p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.textSecondary,
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(p.role).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.role,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getRoleColor(p.role)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getParticipantStatusColor(p.status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _getParticipantStatusColor(p.status)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return AppColors.primary;
      case 'editor':
        return AppColors.accent;
      case 'viewer':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getParticipantStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'banned':
        return AppColors.error;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: contentColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Đang diễn ra';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
