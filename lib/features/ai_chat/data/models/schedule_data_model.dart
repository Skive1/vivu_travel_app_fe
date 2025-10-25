import '../../domain/entities/schedule_data_entity.dart';

class ScheduleDataModel extends ScheduleDataEntity {
  const ScheduleDataModel({
    super.sharedCode,
    required super.title,
    required super.startLocation,
    required super.destination,
    required super.startDate,
    required super.endDate,
    required super.participantsCount,
    required super.notes,
    required super.isShared,
  });

  factory ScheduleDataModel.fromEntity(ScheduleDataEntity entity) {
    return ScheduleDataModel(
      sharedCode: entity.sharedCode,
      title: entity.title,
      startLocation: entity.startLocation,
      destination: entity.destination,
      startDate: entity.startDate,
      endDate: entity.endDate,
      participantsCount: entity.participantsCount,
      notes: entity.notes,
      isShared: entity.isShared,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharedCode': sharedCode,
      'title': title,
      'startLocation': startLocation,
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'participantsCount': participantsCount,
      'notes': notes,
      'isShared': isShared,
    };
  }

  factory ScheduleDataModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDataModel(
      sharedCode: json['sharedCode'] as String?,
      title: json['title'] as String,
      startLocation: json['startLocation'] as String,
      destination: json['destination'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      participantsCount: json['participantsCount'] as int,
      notes: json['notes'] as String,
      isShared: json['isShared'] as bool,
    );
  }
}
