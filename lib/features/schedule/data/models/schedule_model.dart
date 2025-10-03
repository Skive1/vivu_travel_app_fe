import '../../domain/entities/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.sharedCode,
    required super.ownerId,
    required super.title,
    required super.startLocation,
    required super.destination,
    required super.startDate,
    required super.endDate,
    required super.participantsCount,
    required super.notes,
    required super.isShared,
    required super.status,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      sharedCode: json['sharedCode'] as String?,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      startLocation: json['startLocation'] as String,
      destination: json['destination'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participantsCount: json['participantsCount'] as int,
      notes: json['notes'] as String? ?? '',
      isShared: json['isShared'] as bool,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sharedCode': sharedCode,
      'ownerId': ownerId,
      'title': title,
      'startLocation': startLocation,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participantsCount': participantsCount,
      'notes': notes,
      'isShared': isShared,
      'status': status,
    };
  }
}
