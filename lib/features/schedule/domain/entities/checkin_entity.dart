class CheckInEntity {
  final String id;
  final String? checkInTime;
  final String? checkOutTime;
  final String status;
  final int activityId;
  final String participantId;

  const CheckInEntity({
    required this.id,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    required this.activityId,
    required this.participantId,
  });

  bool get isCheckedIn => status == 'CheckIn';
  bool get isCheckedOut => status == 'CheckOut';
}
