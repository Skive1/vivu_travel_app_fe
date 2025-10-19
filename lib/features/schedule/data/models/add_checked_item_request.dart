import 'package:equatable/equatable.dart';

class AddCheckedItemRequest extends Equatable {
  final String name;
  final String scheduleId;

  const AddCheckedItemRequest({
    required this.name,
    required this.scheduleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scheduleId': scheduleId,
    };
  }

  @override
  List<Object> get props => [name, scheduleId];
}
