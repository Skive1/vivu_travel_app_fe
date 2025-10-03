import 'package:equatable/equatable.dart';

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

  const GetActivitiesByScheduleEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class RefreshSchedulesEvent extends ScheduleEvent {
  final String participantId;

  const RefreshSchedulesEvent({required this.participantId});

  @override
  List<Object> get props => [participantId];
}

class RefreshActivitiesEvent extends ScheduleEvent {
  final String scheduleId;

  const RefreshActivitiesEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}

class ShareScheduleEvent extends ScheduleEvent {
  final String scheduleId;

  const ShareScheduleEvent({required this.scheduleId});

  @override
  List<Object> get props => [scheduleId];
}
