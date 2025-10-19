class CheckOutRequest {
  final int activityId;
  final String? file;
  final String? description;

  const CheckOutRequest({
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
