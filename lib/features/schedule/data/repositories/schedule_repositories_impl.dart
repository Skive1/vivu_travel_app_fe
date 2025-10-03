import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

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
}