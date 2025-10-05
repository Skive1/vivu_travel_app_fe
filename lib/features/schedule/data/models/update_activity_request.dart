class UpdateActivityRequest {
  final String placeName;
  final String location;
  final String description;
  final DateTime checkInTime;
  final DateTime checkOutTime;

  UpdateActivityRequest({
    required this.placeName,
    required this.location,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
  });

  Map<String, dynamic> toJson() => {
        'placeName': placeName,
        'location': location,
        'description': description,
        'checkInTime': checkInTime.toIso8601String(),
        'checkOutTime': checkOutTime.toIso8601String(),
      };
}


