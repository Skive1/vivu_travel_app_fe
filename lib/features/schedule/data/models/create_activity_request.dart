class CreateActivityRequest {
  final String placeName;
  final String location;
  final String description;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final int orderIndex;
  final String scheduleId;

  CreateActivityRequest({
    required this.placeName,
    required this.location,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
    required this.orderIndex,
    required this.scheduleId,
  });

  Map<String, dynamic> toJson() => {
        'placeName': placeName,
        'location': location,
        'description': description,
        'checkInTime': checkInTime.toIso8601String(),
        'checkOutTime': checkOutTime.toIso8601String(),
        'orderIndex': orderIndex,
        'scheduleId': scheduleId,
      };
}


