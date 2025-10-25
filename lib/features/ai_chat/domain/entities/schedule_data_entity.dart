class ScheduleDataEntity {
  final String? sharedCode;
  final String title;
  final String startLocation;
  final String destination;
  final String startDate;
  final String endDate;
  final int participantsCount;
  final String notes;
  final bool isShared;

  const ScheduleDataEntity({
    this.sharedCode,
    required this.title,
    required this.startLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    required this.notes,
    required this.isShared,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleDataEntity &&
        other.sharedCode == sharedCode &&
        other.title == title &&
        other.startLocation == startLocation &&
        other.destination == destination &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.participantsCount == participantsCount &&
        other.notes == notes &&
        other.isShared == isShared;
  }

  @override
  int get hashCode {
    return Object.hash(
      sharedCode,
      title,
      startLocation,
      destination,
      startDate,
      endDate,
      participantsCount,
      notes,
      isShared,
    );
  }
}
