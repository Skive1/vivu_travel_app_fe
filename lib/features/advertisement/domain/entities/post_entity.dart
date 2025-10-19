enum PostStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected');

  const PostStatus(this.displayName);
  final String displayName;

  static PostStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PostStatus.pending;
      case 'approved':
        return PostStatus.approved;
      case 'rejected':
        return PostStatus.rejected;
      default:
        return PostStatus.pending;
    }
  }
}

class PostEntity {
  final String id;
  final String partnerId;
  final String title;
  final String description;
  final DateTime postedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final PostStatus status;
  final String statusDisplay;
  final DateTime createdAt;
  final String packagePurchaseId;
  final List<String> mediaIds;
  final List<String> mediaUrls;

  const PostEntity({
    required this.id,
    required this.partnerId,
    required this.title,
    required this.description,
    required this.postedAt,
    this.approvedBy,
    this.approvedAt,
    required this.status,
    required this.statusDisplay,
    required this.createdAt,
    required this.packagePurchaseId,
    required this.mediaIds,
    required this.mediaUrls,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostEntity &&
        other.id == id &&
        other.partnerId == partnerId &&
        other.title == title &&
        other.description == description &&
        other.postedAt == postedAt &&
        other.approvedBy == approvedBy &&
        other.approvedAt == approvedAt &&
        other.status == status &&
        other.statusDisplay == statusDisplay &&
        other.createdAt == createdAt &&
        other.packagePurchaseId == packagePurchaseId &&
        other.mediaIds == mediaIds &&
        other.mediaUrls == mediaUrls;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        partnerId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        postedAt.hashCode ^
        approvedBy.hashCode ^
        approvedAt.hashCode ^
        status.hashCode ^
        statusDisplay.hashCode ^
        createdAt.hashCode ^
        packagePurchaseId.hashCode ^
        mediaIds.hashCode ^
        mediaUrls.hashCode;
  }

  @override
  String toString() {
    return 'PostEntity(id: $id, partnerId: $partnerId, title: $title, description: $description, postedAt: $postedAt, approvedBy: $approvedBy, approvedAt: $approvedAt, status: $status, statusDisplay: $statusDisplay, createdAt: $createdAt, packagePurchaseId: $packagePurchaseId, mediaIds: $mediaIds, mediaUrls: $mediaUrls)';
  }
}
