import 'package:dartz/dartz.dart';
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
import '../models/join_schedule_request.dart';
import '../models/join_schedule_response.dart';
import '../models/add_participant_by_email_request.dart';
import '../models/add_participant_by_email_response.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/entities/kick_participant_result.dart';
import '../../../../core/utils/user_storage.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ScheduleRepositoryImpl({
    required ScheduleRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _networkInfo = networkInfo;

  @override
  Future<List<ScheduleEntity>> getSchedulesByParticipant(
    String participantId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final schedules = await _remoteDataSource.getSchedulesByParticipant(
          participantId,
        );
        return schedules;
      } catch (e) {
        throw ServerFailure(e.toString());
      }
    } else {
      throw NetworkFailure('No internet connection');
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> getScheduleById(String scheduleId) async {
    if (await _networkInfo.isConnected) {
      try {
        print('DEBUG[Repository]: Fetching schedule by ID: $scheduleId');
        final schedule = await _remoteDataSource.getScheduleById(scheduleId);
        
        print('DEBUG[Repository]: Schedule fetched - participantRole: ${schedule.participantRole}');
        
        // Cache the participantRole immediately
        if (schedule.participantRole != null && schedule.participantRole!.isNotEmpty) {
          await UserStorage.setScheduleRole(
            scheduleId: scheduleId,
            role: schedule.participantRole!.toLowerCase(),
          );
          print('DEBUG[Repository]: Cached participantRole: ${schedule.participantRole!.toLowerCase()}');
        } else {
          print('DEBUG[Repository]: No participantRole to cache');
        }
        
        return Right(schedule);
      } catch (e) {
        print('DEBUG[Repository]: Error in getScheduleById: $e');
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final activitiesResponse = await _remoteDataSource.getActivitiesBySchedule(
          scheduleId,
          date,
        );
        
        // Store participant role for this schedule
        if (activitiesResponse.participantRole.isNotEmpty) {
          await UserStorage.setScheduleRole(
            scheduleId: scheduleId, 
            role: activitiesResponse.participantRole.toLowerCase(),
          );
        }
        
        return activitiesResponse.responses
            .where((activity) => !activity.isDeleted)
            .toList();
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
  Future<ScheduleEntity> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final schedule = await _remoteDataSource.updateSchedule(
          scheduleId,
          request,
        );
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
  Future<ActivityEntity> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final activity = await _remoteDataSource.updateActivity(
          activityId,
          request,
        );
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

  @override
  Future<Either<Failure, JoinScheduleResponse>> joinSchedule(JoinScheduleRequest request) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.joinSchedule(request);
        return Right(response);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<ParticipantEntity>>> getScheduleParticipants(String scheduleId) async {
    if (await _networkInfo.isConnected) {
      try {
        final participants = await _remoteDataSource.getScheduleParticipants(scheduleId);
        return Right(participants
            .map((model) => ParticipantEntity(
                  userId: model.userId,
                  name: model.name,
                  role: model.role,
                  status: model.status,
                ))
            .toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, AddParticipantByEmailResponse>> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.addParticipantByEmail(scheduleId, request);
        return Right(response);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, KickParticipantResult>> kickParticipant(String scheduleId, String participantId) async {
    print('DEBUG[Repository]: Starting kick participant');
    print('DEBUG[Repository]: scheduleId = $scheduleId');
    print('DEBUG[Repository]: participantId = $participantId');
    
    if (await _networkInfo.isConnected) {
      print('DEBUG[Repository]: Network is connected, calling remote data source');
      try {
        final response = await _remoteDataSource.kickParticipant(scheduleId, participantId);
        print('DEBUG[Repository]: Remote data source call successful');
        print('DEBUG[Repository]: Response participantCounts = ${response.participantCounts}');
        print('DEBUG[Repository]: Response participants count = ${response.scheduleParticipantResponses.length}');
        
        final entities = response.scheduleParticipantResponses
            .map((m) {
              print('DEBUG[Repository]: Mapping participant: userId=${m.userId}, name=${m.name}, role=${m.role}, status=${m.status}');
              return ParticipantEntity(userId: m.userId, name: m.name, role: m.role, status: m.status);
            })
            .toList();
        
        print('DEBUG[Repository]: Mapped ${entities.length} participant entities');
        
        // Calculate active participants count from entities
        final activeParticipantsCount = entities
            .where((participant) => participant.status == 'Active')
            .length;
        
        print('DEBUG[Repository]: Calculated active participants: $activeParticipantsCount');
        print('DEBUG[Repository]: API participantCounts: ${response.participantCounts}');
        
        final result = KickParticipantResult(
          participantCounts: activeParticipantsCount, // Use calculated active count
          scheduleParticipantResponses: entities,
        );
        
        print('DEBUG[Repository]: KickParticipantResult created successfully');
        return Right(result);
      } catch (e, stackTrace) {
        print('DEBUG[Repository]: Error in kick participant');
        print('DEBUG[Repository]: Error: $e');
        print('DEBUG[Repository]: Stack trace: $stackTrace');
        return Left(ServerFailure(e.toString()));
      }
    } else {
      print('DEBUG[Repository]: No internet connection');
      return Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changeParticipantRole(String scheduleId, String participantId) async {
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.changeParticipantRole(scheduleId, participantId);
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure('No internet connection'));
    }
  }
}
