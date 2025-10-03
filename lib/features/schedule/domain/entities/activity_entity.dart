import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final int id;
  final String placeName;
  final String location;
  final String description;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final int orderIndex;
  final bool isDeleted;
  final String scheduleId;

  const ActivityEntity({
    required this.id,
    required this.placeName,
    required this.location,
    required this.description,
    required this.checkInTime,
    required this.checkOutTime,
    required this.orderIndex,
    required this.isDeleted,
    required this.scheduleId,
  });

  @override
  List<Object?> get props => [
        id,
        placeName,
        location,
        description,
        checkInTime,
        checkOutTime,
        orderIndex,
        isDeleted,
        scheduleId,
      ];
}
