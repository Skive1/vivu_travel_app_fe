class ActivityResponseEntity {
  final int id;
  final String placeName;
  final String location;
  final String? latitude;
  final String? longitude;
  final String description;
  final String checkInTime;
  final String checkOutTime;
  final int orderIndex;
  final bool isDeleted;
  final String? attendanceStatus;
  final String scheduleId;

  const ActivityResponseEntity({
    required this.id,
    required this.placeName,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
    required this.orderIndex,
    required this.isDeleted,
    this.attendanceStatus,
    required this.scheduleId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityResponseEntity &&
        other.id == id &&
        other.placeName == placeName &&
        other.location == location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.description == description &&
        other.checkInTime == checkInTime &&
        other.checkOutTime == checkOutTime &&
        other.orderIndex == orderIndex &&
        other.isDeleted == isDeleted &&
        other.attendanceStatus == attendanceStatus &&
        other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      placeName,
      location,
      latitude,
      longitude,
      description,
      checkInTime,
      checkOutTime,
      orderIndex,
      isDeleted,
      attendanceStatus,
      scheduleId,
    );
  }
}
