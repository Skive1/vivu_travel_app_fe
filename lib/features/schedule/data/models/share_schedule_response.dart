import 'package:equatable/equatable.dart';

class ShareScheduleResponse extends Equatable {
  final String sharedCode;

  const ShareScheduleResponse({
    required this.sharedCode,
  });

  factory ShareScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ShareScheduleResponse(
      sharedCode: json['sharedCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sharedCode': sharedCode,
    };
  }

  @override
  List<Object> get props => [sharedCode];
}
