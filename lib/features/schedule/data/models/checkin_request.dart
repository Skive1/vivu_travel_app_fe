class CheckInRequest {
  final int activityId;
  final String? file;
  final String? description;

  const CheckInRequest({
    required this.activityId,
    this.file,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'ActivityId': activityId,
      if (file != null) 'File': file,
      if (description != null) 'Description': description,
    };
  }
}
