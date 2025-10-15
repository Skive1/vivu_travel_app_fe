class JoinScheduleRequest {
  final String shareCode;

  JoinScheduleRequest({required this.shareCode});

  Map<String, dynamic> toJson() => {
        'shareCode': shareCode,
      };
}
