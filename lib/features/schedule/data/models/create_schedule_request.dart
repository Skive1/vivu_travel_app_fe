class CreateScheduleRequest {
  final String? sharedCode;
  final String title;
  final String startLocation;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final String notes;
  final bool isShared;

  const CreateScheduleRequest({
    this.sharedCode,
    required this.title,
    required this.startLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.participantsCount = 1,
    required this.notes,
    required this.isShared,
  });

  Map<String, dynamic> toJson() {
    return {
      'sharedCode': sharedCode ?? '',
      'title': title,
      'startLocation': startLocation,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participantsCount': participantsCount,
      'notes': notes,
      'isShared': isShared,
    };
  }
}
