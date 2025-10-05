class UpdateScheduleRequest {
  final String title;
  final String startLocation;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final bool isShared;

  const UpdateScheduleRequest({
    required this.title,
    required this.startLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.isShared,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startLocation': startLocation,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'isShared': isShared,
    };
  }
}
