import '../../domain/entities/ai_response_entity.dart';
import 'schedule_data_model.dart';
import 'activity_data_model.dart';

class AIResponseModel extends AIResponseEntity {
  const AIResponseModel({
    required super.success,
    required super.message,
    required super.timestamp,
    required super.aiMessage,
    super.scheduleData,
    super.activitiesData,
  });

  factory AIResponseModel.fromEntity(AIResponseEntity entity) {
    return AIResponseModel(
      success: entity.success,
      message: entity.message,
      timestamp: entity.timestamp,
      aiMessage: entity.aiMessage,
      scheduleData: entity.scheduleData,
      activitiesData: entity.activitiesData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'timestamp': timestamp,
      'aiMessage': aiMessage,
      'scheduleData': scheduleData != null 
          ? ScheduleDataModel.fromEntity(scheduleData!).toJson()
          : null,
      'activitiesData': activitiesData != null
          ? activitiesData!.map((activity) => ActivityDataModel.fromEntity(activity).toJson()).toList()
          : null,
    };
  }

  factory AIResponseModel.fromJson(Map<String, dynamic> json) {
    return AIResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      timestamp: json['timestamp'] as String,
      aiMessage: json['aiMessage'] as String,
      scheduleData: json['scheduleData'] != null
          ? ScheduleDataModel.fromJson(json['scheduleData'] as Map<String, dynamic>)
          : null,
      activitiesData: json['activitiesData'] != null
          ? (json['activitiesData'] as List<dynamic>)
              .map((activity) => ActivityDataModel.fromJson(activity as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
