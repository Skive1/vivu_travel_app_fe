class MediaEntity {
  final int id;
  final int mediaType;
  final String url;
  final String? description;
  final String uploadedAt;
  final String participantId;
  final int uploadMethod;
  final String? scheduleId;
  final int activityId;
  final String? participantName;
  final String? participantAvatar;

  const MediaEntity({
    required this.id,
    required this.mediaType,
    required this.url,
    this.description,
    required this.uploadedAt,
    required this.participantId,
    required this.uploadMethod,
    this.scheduleId,
    required this.activityId,
    this.participantName,
    this.participantAvatar,
  });

  bool get isCheckIn => uploadMethod == 0;
  bool get isCheckOut => uploadMethod == 1;
  bool get isNormal => uploadMethod == 2;
  
  String get uploadMethodText {
    switch (uploadMethod) {
      case 0:
        return 'Check-in';
      case 1:
        return 'Check-out';
      case 2:
        return 'Normal';
      default:
        return 'Unknown';
    }
  }
}
