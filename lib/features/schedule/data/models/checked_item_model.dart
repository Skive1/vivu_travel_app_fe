import 'package:equatable/equatable.dart';

class CheckedItemModel extends Equatable {
  final int checkedItemId;
  final String checkedItemName;
  final bool isChecked;
  final DateTime checkedAt;
  final bool isDeleted;
  final String scheduleParticipantId;

  const CheckedItemModel({
    required this.checkedItemId,
    required this.checkedItemName,
    required this.isChecked,
    required this.checkedAt,
    required this.isDeleted,
    required this.scheduleParticipantId,
  });

  factory CheckedItemModel.fromJson(Map<String, dynamic> json) {
    return CheckedItemModel(
      checkedItemId: json['checkedItemId'] as int,
      checkedItemName: json['checkedItemName'] as String,
      isChecked: json['isChecked'] as bool,
      checkedAt: DateTime.parse(json['checkedAt'] as String),
      isDeleted: json['isDeleted'] as bool,
      scheduleParticipantId: json['scheduleParticipantId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'checkedItemId': checkedItemId,
      'checkedItemName': checkedItemName,
      'isChecked': isChecked,
      'checkedAt': checkedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'scheduleParticipantId': scheduleParticipantId,
    };
  }

  CheckedItemModel copyWith({
    int? checkedItemId,
    String? checkedItemName,
    bool? isChecked,
    DateTime? checkedAt,
    bool? isDeleted,
    String? scheduleParticipantId,
  }) {
    return CheckedItemModel(
      checkedItemId: checkedItemId ?? this.checkedItemId,
      checkedItemName: checkedItemName ?? this.checkedItemName,
      isChecked: isChecked ?? this.isChecked,
      checkedAt: checkedAt ?? this.checkedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      scheduleParticipantId: scheduleParticipantId ?? this.scheduleParticipantId,
    );
  }

  @override
  List<Object> get props => [
        checkedItemId,
        checkedItemName,
        isChecked,
        checkedAt,
        isDeleted,
        scheduleParticipantId,
      ];
}
