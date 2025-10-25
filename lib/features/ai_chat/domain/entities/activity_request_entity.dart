class ActivityRequestEntity {
  final String placeName;
  final String location;
  final String? latitude;
  final String? longitude;
  final String description;
  final String checkInTime;
  final String checkOutTime;
  final int orderIndex;
  final String scheduleId;

  const ActivityRequestEntity({
    required this.placeName,
    required this.location,
    this.latitude,
    this.longitude,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
    required this.orderIndex,
    required this.scheduleId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ActivityRequestEntity &&
        other.placeName == placeName &&
        other.location == location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.description == description &&
        other.checkInTime == checkInTime &&
        other.checkOutTime == checkOutTime &&
        other.orderIndex == orderIndex &&
        other.scheduleId == scheduleId;
  }

  @override
  int get hashCode {
    return Object.hash(
      placeName,
      location,
      latitude,
      longitude,
      description,
      checkInTime,
      checkOutTime,
      orderIndex,
      scheduleId,
    );
  }
}
