import '../../../../core/errors/failures.dart';
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

    if (await _networkInfo.isConnected) {
     
      try {
        final schedule = await _remoteDataSource.createSchedule(request);
        return schedule;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<ScheduleEntity> updateSchedule(String scheduleId, UpdateScheduleRequest request) async {
    
    
    if (await _networkInfo.isConnected) {
      
      try {
        final schedule = await _remoteDataSource.updateSchedule(scheduleId, request);
        return schedule;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
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