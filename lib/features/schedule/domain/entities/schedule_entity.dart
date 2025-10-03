import 'package:equatable/equatable.dart';

class ScheduleEntity extends Equatable {
  final String id;
  final String? sharedCode;
  final String ownerId;
  final String title;
  final String startLocation;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final int participantsCount;
  final String notes;
  final bool isShared;
  final String status;

  const ScheduleEntity({
    required this.id,
    this.sharedCode,
    required this.ownerId,
    required this.title,
    required this.startLocation,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.participantsCount,
    required this.notes,
    required this.isShared,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        sharedCode,
        ownerId,
        title,
        startLocation,
        destination,
        startDate,
        endDate,
        participantsCount,
        notes,
        isShared,
        status,
      ];
}
