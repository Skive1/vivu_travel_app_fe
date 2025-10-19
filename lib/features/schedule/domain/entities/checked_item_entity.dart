import 'package:equatable/equatable.dart';

class CheckedItemEntity extends Equatable {
  final int checkedItemId;
  final String checkedItemName;
  final bool isChecked;
  final DateTime checkedAt;
  final bool isDeleted;
  final String scheduleParticipantId;

  const CheckedItemEntity({
    required this.checkedItemId,
    required this.checkedItemName,
    required this.isChecked,
    required this.checkedAt,
    required this.isDeleted,
    required this.scheduleParticipantId,
  });

  CheckedItemEntity copyWith({
    int? checkedItemId,
    String? checkedItemName,
    bool? isChecked,
    DateTime? checkedAt,
    bool? isDeleted,
    String? scheduleParticipantId,
  }) {
    return CheckedItemEntity(
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
