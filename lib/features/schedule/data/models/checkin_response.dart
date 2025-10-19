class CheckInResponse {
  final String id;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final int activityId;
  final String participantId;

  const CheckInResponse({
    required this.id,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.activityId,
    required this.participantId,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      id: json['id'] as String,
      checkInTime: json['checkInTime'] as String?,
      checkOutTime: json['checkOutTime'] as String?,
      status: json['status'] as String,
      activityId: json['activityId'] as int,
      participantId: json['participantId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'activityId': activityId,
      'participantId': participantId,
    };
  }
}
