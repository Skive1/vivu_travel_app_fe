import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/entities/kick_participant_result.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleEntity> schedules;

  const ScheduleLoaded({required this.schedules});

  @override
  List<Object> get props => [schedules];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class ActivitiesLoading extends ScheduleState {}

class ActivitiesLoaded extends ScheduleState {
  final List<ActivityEntity> activities;
  final int version;

  const ActivitiesLoaded({required this.activities, required this.version});

  @override
  List<Object> get props => [version, activities.length];
}

class ActivitiesError extends ScheduleState {
  final String message;

  const ActivitiesError({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateActivityLoading extends ScheduleState {}

class CreateActivitySuccess extends ScheduleState {
  final ActivityEntity activity;

  const CreateActivitySuccess({required this.activity});

  @override
  List<Object> get props => [activity];
}

class CreateActivityError extends ScheduleState {
  final String message;

  const CreateActivityError({required this.message});

  @override
  List<Object> get props => [message];
}

// Activity-specific update states
class UpdateActivityLoading extends ScheduleState {}

class UpdateActivitySuccess extends ScheduleState {
  final ActivityEntity activity;

  const UpdateActivitySuccess({required this.activity});

  @override
  List<Object> get props => [activity];
}

class UpdateActivityError extends ScheduleState {
  final String message;

  const UpdateActivityError({required this.message});

  @override
  List<Object> get props => [message];
}

// Activity-specific delete states
class DeleteActivityLoading extends ScheduleState {}

class DeleteActivitySuccess extends ScheduleState {
  final String scheduleId;
  final int activityId;

  const DeleteActivitySuccess({required this.scheduleId, required this.activityId});

  @override
  List<Object> get props => [scheduleId, activityId];
}

class DeleteActivityError extends ScheduleState {
  final String message;

  const DeleteActivityError({required this.message});

  @override
  List<Object> get props => [message];
}

class ShareScheduleLoading extends ScheduleState {}

class ShareScheduleSuccess extends ScheduleState {
  final String sharedCode;

  const ShareScheduleSuccess({required this.sharedCode});

  @override
  List<Object> get props => [sharedCode];
}

class ShareScheduleError extends ScheduleState {
  final String message;

  const ShareScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class CreateScheduleLoading extends ScheduleState {}

class CreateScheduleSuccess extends ScheduleState {
  final ScheduleEntity schedule;

  const CreateScheduleSuccess({required this.schedule});

  @override
  List<Object> get props => [schedule];
}

class CreateScheduleError extends ScheduleState {
  final String message;

  const CreateScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class UpdateScheduleLoading extends ScheduleState {}

class UpdateScheduleSuccess extends ScheduleState {
  final ScheduleEntity schedule;

  const UpdateScheduleSuccess({required this.schedule});

  @override
  List<Object> get props => [schedule];
}

class UpdateScheduleError extends ScheduleState {
  final String message;

  const UpdateScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class JoinScheduleLoading extends ScheduleState {}

class JoinScheduleSuccess extends ScheduleState {
  final String message;

  const JoinScheduleSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class JoinScheduleError extends ScheduleState {
  final String message;

  const JoinScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class GetScheduleParticipantsLoading extends ScheduleState {}

class GetScheduleParticipantsSuccess extends ScheduleState {
  final List<ParticipantEntity> participants;
  final int version;

  const GetScheduleParticipantsSuccess({required this.participants, required this.version});

  @override
  List<Object> get props => [version, participants.length];
}

class GetScheduleParticipantsError extends ScheduleState {
  final String message;

  const GetScheduleParticipantsError({required this.message});

  @override
  List<Object> get props => [message];
}

class AddParticipantByEmailLoading extends ScheduleState {}

class AddParticipantByEmailSuccess extends ScheduleState {
  final String message;

  const AddParticipantByEmailSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AddParticipantByEmailError extends ScheduleState {
  final String message;

  const AddParticipantByEmailError({required this.message});

  @override
  List<Object> get props => [message];
}

class KickParticipantLoading extends ScheduleState {}

class KickParticipantSuccess extends ScheduleState {
  final KickParticipantResult result;
  const KickParticipantSuccess({required this.result});

  @override
  List<Object> get props => [result];
}

class KickParticipantError extends ScheduleState {
  final String message;
  const KickParticipantError({required this.message});

  @override
  List<Object> get props => [message];
}

class LeaveScheduleLoading extends ScheduleState {}

class LeaveScheduleSuccess extends ScheduleState {
  final KickParticipantResult result;
  const LeaveScheduleSuccess({required this.result});

  @override
  List<Object> get props => [result];
}

class LeaveScheduleError extends ScheduleState {
  final String message;
  const LeaveScheduleError({required this.message});

  @override
  List<Object> get props => [message];
}

class ChangeParticipantRoleLoading extends ScheduleState {}

class ChangeParticipantRoleSuccess extends ScheduleState {
  final String message;
  const ChangeParticipantRoleSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class GetScheduleByIdLoading extends ScheduleState {}

class GetScheduleByIdSuccess extends ScheduleState {
  final ScheduleEntity schedule;

  const GetScheduleByIdSuccess({required this.schedule});

  @override
  List<Object> get props => [schedule];
}

class GetScheduleByIdError extends ScheduleState {
  final String message;

  const GetScheduleByIdError({required this.message});

  @override
  List<Object> get props => [message];
}

class ChangeParticipantRoleError extends ScheduleState {
  final String message;
  const ChangeParticipantRoleError({required this.message});

  @override
  List<Object> get props => [message];
}

class ReorderActivityLoading extends ScheduleState {}

class ReorderActivitySuccess extends ScheduleState {
  final String message;
  const ReorderActivitySuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class ReorderActivityError extends ScheduleState {
  final String message;
  const ReorderActivityError({required this.message});

  @override
  List<Object> get props => [message];
}