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
