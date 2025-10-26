import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_event.dart';
import '../bloc/ai_chat_state.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/create_schedule_modal.dart';
import '../widgets/add_activities_modal.dart';
import '../widgets/smart_loading_progress.dart';
import '../widgets/schedule_loading_progress.dart';
import '../../domain/entities/activity_request_entity.dart';
import '../../domain/entities/activity_data_entity.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_utils.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({Key? key}) : super(key: key);

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _lastCreatedScheduleId;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: context.responsivePadding(all: 8),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ai_avt.png',
                  width: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
                  height: context.responsiveIconSize(verySmall: 28, small: 30, large: 32),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: context.responsiveSpacing(verySmall: 8, small: 10, large: 12)),
            Text(
              'Vivu AI',
              style: TextStyle(
                fontWeight: FontWeight.w600, 
                fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: context.responsiveMargin(right: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
            ),
            child: IconButton(
              icon: Icon(
                Icons.clear_all, 
                size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
              ),
              onPressed: () {
                context.read<AIChatBloc>().add(ClearChat());
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<AIChatBloc, AIChatState>(
              listener: (context, state) {
                if (state is AIChatSuccess || state is AIChatTyping) {
                  _scrollToBottom();
                }

                // Show success message when activities are added
                if (state is AIChatActivitiesSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã thêm ${state.activities.length} hoạt động thành công!',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }

                // Show error message when activities fail
                if (state is AIChatActivitiesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Lỗi: ${state.message}')),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }

                // Show success message when schedule is created
                if (state is AIChatScheduleSuccess) {
                  _lastCreatedScheduleId =
                      state.schedule.id; // Store the scheduleId
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đã tạo lịch trình "${state.schedule.title}" thành công!',
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }

                // Show error message when schedule creation fails
                if (state is AIChatScheduleError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: AppColors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Lỗi tạo lịch trình: ${state.message}'),
                          ),
                        ],
                      ),
                      backgroundColor: AppColors.error,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AIChatInitial) {
                  return _buildWelcomeMessage();
                }

                if (state is AIChatError) {
                  return _buildErrorState(state.message);
                }

                if (state is AIChatSuccess) {
                  return _buildChatMessages(state.messages);
                }

                if (state is AIChatTyping) {
                  return Column(
                    children: [
                      Expanded(child: _buildChatMessages(state.messages)),
                      const TypingIndicator(),
                    ],
                  );
                }

                if (state is AIChatActivitiesLoading) {
                  return Column(
                    children: [
                      Expanded(child: _buildChatMessages(state.messages)),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: SmartLoadingProgress(
                          title: 'Đang tạo hoạt động',
                          subtitle: 'Vui lòng đợi trong giây lát...',
                          onCancel: () {
                            // TODO: Implement cancel functionality
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is AIChatActivitiesSuccess) {
                  return _buildChatMessages(state.messages);
                }

                if (state is AIChatActivitiesError) {
                  return _buildChatMessages(state.messages);
                }

                if (state is AIChatScheduleLoading) {
                  return Column(
                    children: [
                      Expanded(child: _buildChatMessages(state.messages)),
                      Container(
                        margin: const EdgeInsets.all(16.0),
                        child: ScheduleLoadingProgress(
                          title: 'Đang tạo lịch trình',
                          subtitle: 'Vui lòng đợi trong giây lát...',
                          onCancel: () {
                            // TODO: Implement cancel functionality
                          },
                        ),
                      ),
                    ],
                  );
                }

                if (state is AIChatScheduleSuccess) {
                  return _buildChatMessages(state.messages);
                }

                if (state is AIChatScheduleError) {
                  return _buildChatMessages(state.messages);
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return SingleChildScrollView(
      padding: context.responsivePadding(all: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: context.responsivePadding(all: 24),
            child: Image.asset(
              'assets/images/ai_avt.png',
              width: context.responsiveIconSize(verySmall: 100, small: 110, large: 120),
              height: context.responsiveIconSize(verySmall: 100, small: 110, large: 120),
              fit: BoxFit.cover,
            ),
          ),
          Text(
            'Chào mừng bạn đến với Vivu AI!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: context.responsiveFontSize(verySmall: 20, small: 22, large: 24),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
          Text(
            'Hãy mô tả chuyến du lịch mà bạn muốn thực hiện, tôi sẽ giúp bạn lên kế hoạch chi tiết!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
          _buildExampleCards(),
          SizedBox(height: context.responsiveSpacing(verySmall: 20, small: 22, large: 24)),
          _buildFeatureHighlights(),
          SizedBox(height: context.responsiveSpacing(verySmall: 16, small: 18, large: 20)),
        ],
      ),
    );
  }

  Widget _buildExampleCards() {
    final examples = [
      {
        'title': 'Du lịch trong nước',
        'example':
            'Tôi muốn đi Đà Lạt với bạn bè từ ngày 27/8/2025 đến 29/8/2025',
        'icon': Icons.home,
      },
      {
        'title': 'Du lịch nước ngoài',
        'example':
            'Tôi muốn đi Nhật Bản 7 ngày vào tháng 12, ngân sách 50 triệu',
        'icon': Icons.flight,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ví dụ câu hỏi:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
          ),
        ),
        SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
        ...examples
            .map(
              (example) => Container(
                margin: EdgeInsets.only(bottom: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                padding: context.responsivePadding(all: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textHint.withValues(alpha: 0.1),
                      blurRadius: context.responsiveElevation(verySmall: 3, small: 3.5, large: 4),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          example['icon'] as IconData,
                          color: AppColors.primary,
                          size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
                        ),
                        SizedBox(width: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                        Text(
                          example['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 6, small: 7, large: 8)),
                    Text(
                      '"${example['example']}"',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                        fontSize: context.responsiveFontSize(verySmall: 12, small: 13, large: 14),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'AI Thông minh',
        'description':
            'Sử dụng AI để tạo lịch trình phù hợp với sở thích của bạn',
      },
      {
        'icon': Icons.schedule,
        'title': 'Lịch trình Chi tiết',
        'description': 'Tự động tạo hoạt động với thời gian và địa điểm cụ thể',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tính năng nổi bật:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontSize: context.responsiveFontSize(verySmall: 16, small: 17, large: 18),
          ),
        ),
        SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
        ...features
            .map(
              (feature) => Container(
                margin: EdgeInsets.only(bottom: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                padding: context.responsivePadding(all: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: context.responsivePadding(all: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 6, small: 7, large: 8)),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: AppColors.primary,
                        size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                            ),
                          ),
                          SizedBox(height: context.responsiveSpacing(verySmall: 3, small: 3.5, large: 4)),
                          Text(
                            feature['description'] as String,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: context.responsiveFontSize(verySmall: 11, small: 12, large: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(all: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.responsivePadding(all: 24),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: context.responsiveIconSize(verySmall: 70, small: 75, large: 80),
                color: AppColors.error,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(verySmall: 28, small: 30, large: 32)),
            Text(
              'Có lỗi xảy ra',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
                fontSize: context.responsiveFontSize(verySmall: 20, small: 22, large: 24),
              ),
            ),
            SizedBox(height: context.responsiveSpacing(verySmall: 14, small: 15, large: 16)),
            Container(
              padding: context.responsivePadding(all: 16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 10, small: 11, large: 12)),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                  color: AppColors.error,
                  fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: context.responsiveSpacing(verySmall: 28, small: 30, large: 32)),
            ResponsiveUtils.isVerySmallPhone(context) 
              ? Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<AIChatBloc>().add(ClearChat());
                        },
                        icon: Icon(Icons.refresh, size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18)),
                        label: Text('Làm mới', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15))),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: context.responsivePadding(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Retry last message
                          if (_messageController.text.isNotEmpty) {
                            context.read<AIChatBloc>().add(
                              SendMessage(message: _messageController.text),
                            );
                          }
                        },
                        icon: Icon(Icons.replay, size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18)),
                        label: Text('Thử lại', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: context.responsivePadding(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<AIChatBloc>().add(ClearChat());
                      },
                      icon: Icon(Icons.refresh, size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18)),
                      label: Text('Làm mới', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15))),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: context.responsivePadding(vertical: 12),
                      ),
                    ),
                    SizedBox(width: context.responsiveSpacing(verySmall: 12, small: 14, large: 16)),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Retry last message
                        if (_messageController.text.isNotEmpty) {
                          context.read<AIChatBloc>().add(
                            SendMessage(message: _messageController.text),
                          );
                        }
                      },
                      icon: Icon(Icons.replay, size: context.responsiveIconSize(verySmall: 16, small: 17, large: 18)),
                      label: Text('Thử lại', style: TextStyle(fontSize: context.responsiveFontSize(verySmall: 13, small: 14, large: 15))),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: context.responsivePadding(vertical: 12),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessages(List messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: context.responsivePadding(vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message,
          onCreateSchedule: () => _onCreateSchedule(message),
          onAddActivities: () => _onAddActivities(message),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: context.responsivePadding(all: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textHint.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: context.responsiveElevation(verySmall: 6, small: 7, large: 8),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(verySmall: 20, small: 22, large: 24)),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn của bạn...',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: context.responsiveFontSize(verySmall: 14, small: 15, large: 16),
                    ),
                    border: InputBorder.none,
                    contentPadding: context.responsivePadding(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: _messageController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.textHint,
                              size: context.responsiveIconSize(verySmall: 18, small: 19, large: 20),
                            ),
                            onPressed: () {
                              _messageController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _sendMessage();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: context.responsiveSpacing(verySmall: 10, small: 11, large: 12)),
            Container(
              decoration: BoxDecoration(
                color: _messageController.text.trim().isNotEmpty
                    ? AppColors.primary
                    : AppColors.textHint,
                shape: BoxShape.circle,
                boxShadow: _messageController.text.trim().isNotEmpty
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: context.responsiveElevation(verySmall: 6, small: 7, large: 8),
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color: _messageController.text.trim().isNotEmpty
                      ? AppColors.white
                      : AppColors.textSecondary,
                  size: context.responsiveIconSize(verySmall: 20, small: 22, large: 24),
                ),
                onPressed: _messageController.text.trim().isNotEmpty
                    ? () {
                        _sendMessage();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<AIChatBloc>().add(SendMessage(message: message));
      _messageController.clear();
      setState(() {}); // Update UI to reflect cleared text
    }
  }

  void _onCreateSchedule(dynamic message) {
    if (message.aiResponse?.scheduleData != null) {
      showDialog(
        context: context,
        builder: (dialogContext) => CreateScheduleModal(
          scheduleData: message.aiResponse!.scheduleData!,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            context.read<AIChatBloc>().add(
              CreateSchedule(scheduleData: message.aiResponse!.scheduleData!),
            );
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        ),
      );
    }
  }

  void _onAddActivities(dynamic message) {
    if (message.aiResponse?.activitiesData != null) {
      // Check if schedule has been created
      if (_lastCreatedScheduleId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Vui lòng tạo lịch trình trước khi thêm hoạt động.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }

      // Convert ActivityDataEntity to ActivityRequestEntity with real scheduleId
      final activities = _convertToActivityRequests(
        message.aiResponse!.activitiesData!,
        _lastCreatedScheduleId!,
      );

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (dialogContext) => AddActivitiesModal(
          activities: message.aiResponse!.activitiesData!,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            context.read<AIChatBloc>().add(
              AddListActivities(activities: activities),
            );
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        ),
      );
    }
  }

  List<ActivityRequestEntity> _convertToActivityRequests(
    List<ActivityDataEntity> activitiesData,
    String scheduleId,
  ) {
    return activitiesData.map((activity) {
      return ActivityRequestEntity(
        placeName: activity.placeName,
        location: activity.location,
        latitude: activity.latitude?.toString(),
        longitude: activity.longitude?.toString(),
        description: activity.description,
        checkInTime: activity.checkInTime,
        checkOutTime: activity.checkOutTime,
        orderIndex: activity.orderIndex,
        scheduleId: scheduleId, // Use the real scheduleId from created schedule
      );
    }).toList();
  }
}
