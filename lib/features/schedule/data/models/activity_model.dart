import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.placeName,
    required super.location,
    required super.description,
    required super.checkInTime,
    required super.checkOutTime,
    required super.orderIndex,
    required super.isDeleted,
    required super.scheduleId,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int,
      placeName: json['placeName'] as String,
      location: json['location'] as String,
      description: json['description'] as String? ?? '',
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: DateTime.parse(json['checkOutTime'] as String),
      orderIndex: json['orderIndex'] as int,
      isDeleted: json['isDeleted'] as bool,
      scheduleId: json['scheduleId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeName': placeName,
      'location': location,
      'description': description,
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime.toIso8601String(),
      'orderIndex': orderIndex,
      'isDeleted': isDeleted,
      'scheduleId': scheduleId,
    };
  }
}
