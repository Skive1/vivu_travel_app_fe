import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.partnerId,
    required super.title,
    required super.description,
    required super.postedAt,
    super.approvedBy,
    super.approvedAt,
    required super.status,
    required super.statusDisplay,
    required super.createdAt,
    required super.packagePurchaseId,
    required super.mediaIds,
    required super.mediaUrls,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      postedAt: DateTime.parse(json['postedAt'] as String),
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      status: PostStatus.fromString(json['status'] as String),
      statusDisplay: json['statusDisplay'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      packagePurchaseId: json['packagePurchaseId'] as String,
      mediaIds: List<String>.from(json['mediaIds'] as List),
      mediaUrls: List<String>.from(json['mediaUrls'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'title': title,
      'description': description,
      'postedAt': postedAt.toIso8601String(),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'status': status.name,
      'statusDisplay': statusDisplay,
      'createdAt': createdAt.toIso8601String(),
      'packagePurchaseId': packagePurchaseId,
      'mediaIds': mediaIds,
      'mediaUrls': mediaUrls,
    };
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      partnerId: partnerId,
      title: title,
      description: description,
      postedAt: postedAt,
      approvedBy: approvedBy,
      approvedAt: approvedAt,
      status: status,
      statusDisplay: statusDisplay,
      createdAt: createdAt,
      packagePurchaseId: packagePurchaseId,
      mediaIds: mediaIds,
      mediaUrls: mediaUrls,
    );
  }
}
