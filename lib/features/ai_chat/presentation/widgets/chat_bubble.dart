import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'typewriter_effect.dart';
import 'schedule_card.dart';
import 'activities_table.dart';
import 'ai_action_buttons.dart';
import 'markdown_renderer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../../authentication/domain/entities/user_entity.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isTyping;
  final VoidCallback? onCreateSchedule;
  final VoidCallback? onAddActivities;

  const ChatBubble({
    Key? key,
    required this.message,
    this.isTyping = false,
    this.onCreateSchedule,
    this.onAddActivities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Reduced horizontal margin
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ai_avt.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser 
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: message.isUser 
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isTyping)
                    TypewriterEffect(
                      text: message.content,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    )
                  else if (message.isUser)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    )
                  else
                    // AI message with markdown support
                    MarkdownRenderer(
                      text: message.content,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  // Show schedule data and activities if available
                  if (!message.isUser && message.aiResponse != null) ...[
                    const SizedBox(height: 16),
                    if (message.aiResponse!.scheduleData != null)
                      ScheduleCard(scheduleData: message.aiResponse!.scheduleData!),
                    if (message.aiResponse!.activitiesData != null && 
                        message.aiResponse!.activitiesData!.isNotEmpty)
                      ActivitiesTable(activities: message.aiResponse!.activitiesData!),
                    // Show action buttons
                    AIActionButtons(
                      scheduleData: message.aiResponse!.scheduleData,
                      activitiesData: message.aiResponse!.activitiesData,
                      onCreateSchedule: onCreateSchedule,
                      onAddActivities: onAddActivities,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated && state.hasUserProfile) {
          final user = state.userEntity!;
          return _buildAvatar(user);
        }
        
        // Show placeholder when user profile is not available
        return _buildPlaceholderAvatar();
      },
    );
  }

  Widget _buildAvatar(UserEntity user) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: user.hasValidAvatar 
          ? _buildNetworkAvatar(user.avatar!, user.avatarInitials)
          : _buildInitialsAvatar(user.avatarInitials),
    );
  }

  Widget _buildNetworkAvatar(String avatarUrl, String initials) {
    return ClipOval(
      child: Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar(initials);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildInitialsAvatar(initials);
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: const Icon(
        Icons.person,
        color: Colors.grey,
        size: 16,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
