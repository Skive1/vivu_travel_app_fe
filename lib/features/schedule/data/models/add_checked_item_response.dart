import 'package:equatable/equatable.dart';

class AddCheckedItemResponse extends Equatable {
  final int id;
  final String name;
  final String scheduleId;

  const AddCheckedItemResponse({
    required this.id,
    required this.name,
    required this.scheduleId,
  });

  factory AddCheckedItemResponse.fromJson(Map<String, dynamic> json) {
    return AddCheckedItemResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      scheduleId: json['scheduleId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scheduleId': scheduleId,
    };
  }

  @override
  List<Object> get props => [id, name, scheduleId];
}
