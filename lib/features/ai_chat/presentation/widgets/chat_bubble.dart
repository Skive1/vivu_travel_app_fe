import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'typewriter_effect.dart';
import 'schedule_card.dart';
import 'activities_table.dart';
import 'ai_action_buttons.dart';
import 'markdown_renderer.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';
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
      margin: context.responsiveMargin(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: context.responsiveIconSize(verySmall: 14, small: 15, large: 16),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ai_avt.png',
                  width: context.responsiveIconSize(verySmall: 56, small: 60, large: 64),
                  height: context.responsiveIconSize(verySmall: 56, small: 60, large: 64),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
          ],
          Flexible(
            child: Container(
              padding: context.responsivePadding(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 18, small: 19, large: 20)).copyWith(
                  bottomLeft: message.isUser 
                      ? Radius.circular(context.responsiveBorderRadius(verySmall: 18, small: 19, large: 20))
                      : Radius.circular(context.responsiveBorderRadius(verySmall: 3, small: 3.5, large: 4)),
                  bottomRight: message.isUser 
                      ? Radius.circular(context.responsiveBorderRadius(verySmall: 3, small: 3.5, large: 4))
                      : Radius.circular(context.responsiveBorderRadius(verySmall: 18, small: 19, large: 20)),
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
                        fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                      ),
                    )
                  else if (message.isUser)
                    Text(
                      message.content,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                      ),
                    )
                  else
                    // AI message with markdown support
                    MarkdownRenderer(
                      text: message.content,
                    ),
                  SizedBox(height: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white70 
                          : Colors.grey[600],
                      fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
                    ),
                  ),
                  // Show schedule data and activities if available
                  if (!message.isUser && message.aiResponse != null) ...[
                    SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
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
            SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
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
          return _buildAvatar(user, context);
        }
        
        // Show placeholder when user profile is not available
        return _buildPlaceholderAvatar(context);
      },
    );
  }

  Widget _buildAvatar(UserEntity user, BuildContext context) {
    return Container(
      width: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
      height: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: user.hasValidAvatar 
          ? _buildNetworkAvatar(user.avatar!, user.avatarInitials, context)
          : _buildInitialsAvatar(user.avatarInitials, context),
    );
  }

  Widget _buildNetworkAvatar(String avatarUrl, String initials, BuildContext context) {
    return ClipOval(
      child: Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildInitialsAvatar(initials, context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildInitialsAvatar(initials, context);
        },
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials, BuildContext context) {
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
          style: TextStyle(
            color: Colors.white,
            fontSize: context.responsiveFontSize(verySmall: 10, small: 11, large: 12),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Container(
      width: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
      height: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey,
        size: context.responsiveIconSize(verySmall: 14, small: 15, large: 16),
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
