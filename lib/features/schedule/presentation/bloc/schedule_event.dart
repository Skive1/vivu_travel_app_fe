import 'package:equatable/equatable.dart';
import '../../data/models/create_schedule_request.dart';
import '../../data/models/update_schedule_request.dart';
import '../../data/models/create_activity_request.dart';
import '../../data/models/update_activity_request.dart';
import '../../data/models/join_schedule_request.dart';
import '../../data/models/add_participant_by_email_request.dart';
import '../../data/models/add_checked_item_request.dart';
import '../../data/models/checkin_request.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/upload_media_request.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object> get props => [];
}

class GetSchedulesByParticipantEvent extends ScheduleEvent {
  final String participantId;

  const GetSchedulesByParticipantEvent({required this.participantId});

  @override
  List<Object> get props => [participantId];
}

class GetActivitiesByScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final DateTime date;

  const GetActivitiesByScheduleEvent({
    required this.scheduleId,
    required this.date,
  });

  @override
  List<Object> get props => [scheduleId, date];
}

class RefreshSchedulesEvent extends ScheduleEvent {
  final String participantId;

  const RefreshSchedulesEvent({required this.participantId});

  @override
  List<Object> get props => [participantId];
}

class RefreshActivitiesEvent extends ScheduleEvent {
  final String scheduleId;
  final DateTime date;

  const RefreshActivitiesEvent({required this.scheduleId, required this.date});

  @override
  List<Object> get props => [scheduleId, date];
}

class ShareScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const ShareScheduleEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class CreateScheduleEvent extends ScheduleEvent {
  final CreateScheduleRequest request;

  const CreateScheduleEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class UpdateScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final UpdateScheduleRequest request;

  const UpdateScheduleEvent({required this.scheduleId, required this.request});

  @override
  List<Object> get props => [scheduleId, request];
}

class ClearCacheEvent extends ScheduleEvent {
  const ClearCacheEvent();
}

class CreateActivityEvent extends ScheduleEvent {
  final CreateActivityRequest request;

  const CreateActivityEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class UpdateActivityEvent extends ScheduleEvent {
  final int activityId;
  final UpdateActivityRequest request;

  const UpdateActivityEvent({required this.activityId, required this.request});

  @override
  List<Object> get props => [activityId, request];
}

class DeleteActivityEvent extends ScheduleEvent {
  final int activityId;
  final String scheduleId;
  final DateTime date;

  const DeleteActivityEvent({
    required this.activityId,
    required this.scheduleId,
    required this.date,
  });

  @override
  List<Object> get props => [activityId, scheduleId, date];
}

class JoinScheduleEvent extends ScheduleEvent {
  final JoinScheduleRequest request;

  const JoinScheduleEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class GetScheduleParticipantsEvent extends ScheduleEvent {
  final String scheduleId;

  const GetScheduleParticipantsEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class AddParticipantByEmailEvent extends ScheduleEvent {
  final String scheduleId;
  final AddParticipantByEmailRequest request;

  const AddParticipantByEmailEvent({
    required this.scheduleId,
    required this.request,
  });

  @override
  List<Object> get props => [scheduleId, request];
}

class KickParticipantEvent extends ScheduleEvent {
  final String scheduleId;
  final String participantId;

  const KickParticipantEvent({required this.scheduleId, required this.participantId});

  @override
  List<Object> get props => [scheduleId, participantId];
}

class LeaveScheduleEvent extends ScheduleEvent {
  final String scheduleId;
  final String userId;

  const LeaveScheduleEvent({required this.scheduleId, required this.userId});

  @override
  List<Object> get props => [scheduleId, userId];
}

class GetScheduleByIdEvent extends ScheduleEvent {
  final String scheduleId;

  const GetScheduleByIdEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ChangeParticipantRoleEvent extends ScheduleEvent {
  final String scheduleId;
  final String participantId;

  const ChangeParticipantRoleEvent({required this.scheduleId, required this.participantId});

  @override
  List<Object> get props => [scheduleId, participantId];
}

class ReorderActivityEvent extends ScheduleEvent {
  final int activityId;
  final int newIndex;
  final String scheduleId;
  final DateTime date;

  const ReorderActivityEvent({required this.activityId, required this.newIndex, required this.scheduleId, required this.date});

  @override
  List<Object> get props => [activityId, newIndex, scheduleId, date];
}

// Checked items events
class GetCheckedItemsEvent extends ScheduleEvent {
  final String scheduleId;

  const GetCheckedItemsEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class AddCheckedItemEvent extends ScheduleEvent {
  final List<AddCheckedItemRequest> request;

  const AddCheckedItemEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class ToggleCheckedItemEvent extends ScheduleEvent {
  final int checkedItemId;
  final bool isChecked;

  const ToggleCheckedItemEvent({required this.checkedItemId, required this.isChecked});

  @override
  List<Object> get props => [checkedItemId, isChecked];
}

class DeleteCheckedItemsBulkEvent extends ScheduleEvent {
  final List<int> checkedItemIds;

  const DeleteCheckedItemsBulkEvent({required this.checkedItemIds});

  @override
  List<Object> get props => [checkedItemIds];
}

class CancelScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const CancelScheduleEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class RestoreScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const RestoreScheduleEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

// Check-in/Check-out events
class CheckInActivityEvent extends ScheduleEvent {
  final CheckInRequest request;

  const CheckInActivityEvent({required this.request});

  @override
  List<Object> get props => [request];
}

class CheckOutActivityEvent extends ScheduleEvent {
  final CheckOutRequest request;

  const CheckOutActivityEvent({required this.request});

  @override
  List<Object> get props => [request];
}

// Media events
class GetMediaByActivityEvent extends ScheduleEvent {
  final int activityId;

  const GetMediaByActivityEvent({required this.activityId});

  @override
  List<Object> get props => [activityId];
}

class UploadMediaEvent extends ScheduleEvent {
  final UploadMediaRequest request;

  const UploadMediaEvent({required this.request});

  @override
  List<Object> get props => [request];
}