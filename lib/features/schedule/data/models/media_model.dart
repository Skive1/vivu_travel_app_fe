class MediaModel {
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

  const MediaModel({
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

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'] as int,
      mediaType: json['mediaType'] as int,
      url: json['url'] as String,
      description: json['description'] as String?,
      uploadedAt: json['uploadedAt'] as String,
      participantId: json['participantId'] as String,
      uploadMethod: json['uploadMethod'] as int,
      scheduleId: json['scheduleId'] as String?,
      activityId: json['activityId'] as int,
      participantName: json['participantName'] as String?,
      participantAvatar: json['participantAvatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaType': mediaType,
      'url': url,
      'description': description,
      'uploadedAt': uploadedAt,
      'participantId': participantId,
      'uploadMethod': uploadMethod,
      'scheduleId': scheduleId,
      'activityId': activityId,
      'participantName': participantName,
      'participantAvatar': participantAvatar,
    };
  }

  // Helper methods
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
