import '../../domain/entities/activity_response_entity.dart';

class ActivityResponseModel extends ActivityResponseEntity {
  const ActivityResponseModel({
    required super.id,
    required super.placeName,
    required super.location,
    super.latitude,
    super.longitude,
    required super.description,
    required super.checkInTime,
    required super.checkOutTime,
    required super.orderIndex,
    required super.isDeleted,
    super.attendanceStatus,
    required super.scheduleId,
  });

  factory ActivityResponseModel.fromEntity(ActivityResponseEntity entity) {
    return ActivityResponseModel(
      id: entity.id,
      placeName: entity.placeName,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      description: entity.description,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      orderIndex: entity.orderIndex,
      isDeleted: entity.isDeleted,
      attendanceStatus: entity.attendanceStatus,
      scheduleId: entity.scheduleId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeName': placeName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'orderIndex': orderIndex,
      'isDeleted': isDeleted,
      'attendanceStatus': attendanceStatus,
      'scheduleId': scheduleId,
    };
  }

  factory ActivityResponseModel.fromJson(Map<String, dynamic> json) {
    return ActivityResponseModel(
      id: json['id'] as int,
      placeName: json['placeName'] as String,
      location: json['location'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      description: json['description'] as String,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      orderIndex: json['orderIndex'] as int,
      isDeleted: json['isDeleted'] as bool,
      attendanceStatus: json['attendanceStatus'] as String?,
      scheduleId: json['scheduleId'] as String,
    );
  }
}
