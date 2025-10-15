class JoinScheduleResponse {
  final String message;

  JoinScheduleResponse({required this.message});

  factory JoinScheduleResponse.fromJson(Map<String, dynamic> json) {
    return JoinScheduleResponse(
      message: json['message'] as String,
    );
  }
}
