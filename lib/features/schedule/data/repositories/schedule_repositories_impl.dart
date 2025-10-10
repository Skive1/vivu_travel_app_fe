import '../../../../core/errors/failures.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';
import '../models/create_schedule_request.dart';
import '../models/update_schedule_request.dart';
import '../models/create_activity_request.dart';
import '../models/update_activity_request.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ScheduleRepositoryImpl({
    required ScheduleRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  void _d(String message) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(message);
    }
  }

  @override
  Future<List<ScheduleEntity>> getSchedulesByParticipant(String participantId) async {
    if (await _networkInfo.isConnected) {
      try {
        final schedules = await _remoteDataSource.getSchedulesByParticipant(participantId);
        return schedules;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesBySchedule(String scheduleId) async {
    if (await _networkInfo.isConnected) {
      try {
        final activities = await _remoteDataSource.getActivitiesBySchedule(scheduleId);
        return activities;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<String> shareSchedule(String scheduleId) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.shareSchedule(scheduleId);
        return response.sharedCode;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<ScheduleEntity> createSchedule(CreateScheduleRequest request) async {
    _d('🌐 ScheduleRepository: createSchedule called');
    _d('🌐 Request prepared');
    
    if (await _networkInfo.isConnected) {
      _d('🌐 Network connected, calling remote data source');
      try {
        final schedule = await _remoteDataSource.createSchedule(request);
        _d('✅ ScheduleRepository: Success - ${schedule.id}');
        return schedule;
      } catch (e) {
        _d('❌ ScheduleRepository: Error');
        throw ServerFailure(e.toString());
      }
    } else {
      _d('❌ ScheduleRepository: No internet connection');
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<ScheduleEntity> updateSchedule(String scheduleId, UpdateScheduleRequest request) async {
    _d('🌐 ScheduleRepository: updateSchedule called');
    _d('🌐 ScheduleId: $scheduleId');
    _d('🌐 Request prepared');
    
    if (await _networkInfo.isConnected) {
      _d('🌐 Network connected, calling remote data source');
      try {
        final schedule = await _remoteDataSource.updateSchedule(scheduleId, request);
        _d('✅ ScheduleRepository: Update Success - ${schedule.id}');
        return schedule;
      } catch (e) {
        _d('❌ ScheduleRepository: Update Error');
        throw ServerFailure(e.toString());
      }
    } else {
      _d('❌ ScheduleRepository: No internet connection');
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<ActivityEntity> addActivity(CreateActivityRequest request) async {
    if (await _networkInfo.isConnected) {
      try {
        final activity = await _remoteDataSource.addActivity(request);
        return activity;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<ActivityEntity> updateActivity(int activityId, UpdateActivityRequest request) async {
    if (await _networkInfo.isConnected) {
      try {
        final activity = await _remoteDataSource.updateActivity(activityId, request);
        return activity;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteActivity(activityId);
        return;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }
}