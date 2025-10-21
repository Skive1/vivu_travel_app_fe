import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.notificationId,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    required super.senderId,
    required super.senderName,
    required super.recipientId,
    required super.isRead,
    super.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      notificationId: json['notificationId'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      recipientId: json['recipientId'] as String,
      isRead: json['isRead'] as bool,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'senderId': senderId,
      'senderName': senderName,
      'recipientId': recipientId,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
    };
  }
}
