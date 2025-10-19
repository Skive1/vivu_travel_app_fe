class UploadMediaRequest {
  final String? file;
  final String? description;
  final int uploadMethod;
  final String? scheduleId;
  final int activityId;

  const UploadMediaRequest({
    this.file,
    this.description,
    required this.uploadMethod,
    this.scheduleId,
    required this.activityId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (file != null) 'File': file,
      if (description != null) 'Description': description,
      'UploadMethod': uploadMethod,
      if (scheduleId != null) 'ScheduleId': scheduleId,
      'ActivityId': activityId,
    };
  }
}
