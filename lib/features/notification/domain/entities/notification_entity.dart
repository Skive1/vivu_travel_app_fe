import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String notificationId;
  final String title;
  final String message;
  final int type;
  final DateTime createdAt;
  final String senderId;
  final String senderName;
  final String recipientId;
  final bool isRead;
  final DateTime? readAt;

  const NotificationEntity({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.isRead,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        notificationId,
        title,
        message,
        type,
        createdAt,
        senderId,
        senderName,
        recipientId,
        isRead,
        readAt,
      ];
}
