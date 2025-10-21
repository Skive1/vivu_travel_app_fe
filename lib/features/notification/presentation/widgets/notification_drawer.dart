import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => _NotificationDrawerState();
}

class _NotificationDrawerState extends State<NotificationDrawer> {
  @override
  void initState() {
    super.initState();
    // Load notifications when drawer opens
    context.read<NotificationBloc>().add(const GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.75; // Chiếm 3/4 màn hình
    
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: Column(
          children: [
            // Header đơn giản hơn để tránh overflow
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Nút đóng
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Title
                      const Expanded(
                        child: Text(
                          'Thông báo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Icon thông báo
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_active,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
            // Notifications list
            Expanded(
              child: BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is NotificationError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Có lỗi xảy ra',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<NotificationBloc>().add(
                                const GetNotificationsEvent(),
                              );
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is NotificationLoaded) {
                    if (state.notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có thông báo nào',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bạn sẽ nhận được thông báo khi có cập nhật mới',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.notifications.length,
                      itemBuilder: (context, index) {
                        final notification = state.notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () {
                            if (!notification.isRead) {
                              context.read<NotificationBloc>().add(
                                MarkNotificationAsReadEvent(
                                  notificationRecipientId: notification.id,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final dynamic notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final createdAt = notification.createdAt;
    final timeAgo = _getTimeAgo(createdAt);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead 
                ? AppColors.border 
                : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: notification.isRead 
                          ? FontWeight.w500 
                          : FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Từ: ${notification.senderName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
