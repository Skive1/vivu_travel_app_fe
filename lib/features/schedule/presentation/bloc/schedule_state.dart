import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';

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

  const ActivitiesLoaded({required this.activities});

  @override
  List<Object> get props => [activities];
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