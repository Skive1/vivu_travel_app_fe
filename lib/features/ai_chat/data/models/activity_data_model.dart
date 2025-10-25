import '../../domain/entities/activity_data_entity.dart';

class ActivityDataModel extends ActivityDataEntity {
  const ActivityDataModel({
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

  factory ActivityDataModel.fromEntity(ActivityDataEntity entity) {
    return ActivityDataModel(
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

  factory ActivityDataModel.fromJson(Map<String, dynamic> json) {
    return ActivityDataModel(
      placeName: json['placeName'] as String,
      location: json['location'] as String,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      description: json['description'] as String,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String,
      orderIndex: json['orderIndex'] as int,
      scheduleId: json['scheduleId'] as String,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
