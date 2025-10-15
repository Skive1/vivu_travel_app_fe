import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/participant_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class ParticipantsCompact extends StatefulWidget {
  final String scheduleId;
  final String? currentUserId;

  const ParticipantsCompact({
    Key? key,
    required this.scheduleId,
    this.currentUserId,
  }) : super(key: key);

  @override
  State<ParticipantsCompact> createState() => _ParticipantsCompactState();
}

class _ParticipantsCompactState extends State<ParticipantsCompact> {
  @override
  void initState() {
    super.initState();
    // Load participants when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScheduleBloc>().add(
        GetScheduleParticipantsEvent(scheduleId: widget.scheduleId),
      );
    });
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
              // Header
              Row(
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
                  else
                    Text(
                      '${participants.length} người',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Participants list
              if (errorMessage != null)
                _buildErrorState()
              else if (participants.isEmpty)
                _buildEmptyState()
              else
                _buildParticipantsList(participants),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Row(
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
    );
  }

  Widget _buildEmptyState() {
    return Row(
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
    );
  }

  Widget _buildParticipantsList(List<ParticipantEntity> participants) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: participants.take(6).map((participant) {
        final isOwner = widget.currentUserId == participant.userId;
        return _buildParticipantChip(participant, isOwner);
      }).toList()
        ..addAll(participants.length > 6 ? [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              '+${participants.length - 6}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ] : []),
    );
  }

  Widget _buildParticipantChip(ParticipantEntity participant, bool isOwner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOwner 
          ? AppColors.primary.withValues(alpha: 0.1)
          : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwner ? AppColors.primary : AppColors.border,
          width: isOwner ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: isOwner ? AppColors.primary : AppColors.textSecondary,
            child: Text(
              participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            participant.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isOwner ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (isOwner) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.star,
              size: 12,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }
}
