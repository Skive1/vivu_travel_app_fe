import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/participant_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class ParticipantsSection extends StatefulWidget {
  final String scheduleId;
  final String? currentUserId;

  const ParticipantsSection({
    Key? key,
    required this.scheduleId,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<ParticipantsSection> createState() => _ParticipantsSectionState();
}

class _ParticipantsSectionState extends State<ParticipantsSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Load participants when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleBloc>().add(
        GetScheduleParticipantsEvent(scheduleId: widget.scheduleId),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScheduleBloc, ScheduleState>(
      builder: (context, state) {
        List<ParticipantEntity> participants = [];
        bool isLoading = false;
        String? errorMessage;

        if (state is GetScheduleParticipantsLoading) {
          isLoading = true;
        } else if (state is GetScheduleParticipantsSuccess) {
          participants = state.participants;
        } else if (state is GetScheduleParticipantsError) {
          errorMessage = state.message;
        }

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
              // Header với icon và số lượng
              InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Người đã tham gia',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    else if (errorMessage != null)
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 16,
                      )
                    else ...[
                      Text(
                        '${participants.length} người',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Danh sách participants với animation
              AnimatedBuilder(
                animation: _heightAnimation,
                builder: (context, child) {
                  return ClipRect(
                    child: Align(
                      heightFactor: _heightAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: _buildParticipantsList(participants, errorMessage),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParticipantsList(List<ParticipantEntity> participants, String? errorMessage) {
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Không thể tải danh sách',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (participants.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.people_outline,
              color: AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Chưa có người tham gia',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: participants.take(3).map((participant) {
        final isOwner = widget.currentUserId == participant.userId;
        return _buildParticipantItem(participant, isOwner);
      }).toList()
        ..addAll(participants.length > 3 ? [
          const SizedBox(height: 8),
          Text(
            '+${participants.length - 3} người khác',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ] : []),
    );
  }

  Widget _buildParticipantItem(ParticipantEntity participant, bool isOwner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Avatar đơn giản
          CircleAvatar(
            radius: 16,
            backgroundColor: isOwner ? AppColors.primary : AppColors.textSecondary,
            child: Text(
              participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Tên người tham gia
          Expanded(
            child: Row(
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Chủ lịch trình',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Icon trạng thái
          Icon(
            Icons.check_circle,
            color: const Color(0xFF4CAF50),
            size: 16,
          ),
        ],
      ),
    );
  }
}
