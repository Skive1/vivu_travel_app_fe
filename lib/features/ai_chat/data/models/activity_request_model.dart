import '../../domain/entities/activity_request_entity.dart';

class ActivityRequestModel extends ActivityRequestEntity {
  const ActivityRequestModel({
    required super.placeName,
    required super.location,
    super.latitude,
    super.longitude,
    required super.description,
    required super.checkInTime,
    required super.checkOutTime,
    required super.orderIndex,
    required super.scheduleId,
  });

  factory ActivityRequestModel.fromEntity(ActivityRequestEntity entity) {
    return ActivityRequestModel(
      placeName: entity.placeName,
      location: entity.location,
      latitude: entity.latitude,
      longitude: entity.longitude,
      description: entity.description,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      orderIndex: entity.orderIndex,
      scheduleId: entity.scheduleId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'orderIndex': orderIndex,
      'scheduleId': scheduleId,
    };
  }

  factory ActivityRequestModel.fromJson(Map<String, dynamic> json) {
    return ActivityRequestModel(
      placeName: json['placeName'] as String,
      location: json['location'] as String,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      description: json['description'] as String,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      orderIndex: json['orderIndex'] as int,
      scheduleId: json['scheduleId'] as String,
    );
  }
}
