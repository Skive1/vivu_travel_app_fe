import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
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
import '../../domain/entities/checked_item_entity.dart';
import '../models/add_checked_item_request.dart';
import '../models/add_checked_item_response.dart';
import '../models/checkin_request.dart';
import '../models/checkout_request.dart';
import '../models/upload_media_request.dart';
import '../../domain/entities/checkin_entity.dart';
import '../../domain/entities/media_entity.dart';
import '../../../../core/utils/user_storage.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource _remoteDataSource;

  ScheduleRepositoryImpl({
    required ScheduleRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<ScheduleEntity>> getSchedulesByParticipant(
    String participantId,
  ) async {
    try {
      final schedules = await _remoteDataSource.getSchedulesByParticipant(
        participantId,
      );
      return schedules;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> getScheduleById(String scheduleId) async {
    try {
      final schedule = await _remoteDataSource.getScheduleById(scheduleId);
      
      // Cache the participantRole immediately
      if (schedule.participantRole != null && schedule.participantRole!.isNotEmpty) {
        await UserStorage.setScheduleRole(
          scheduleId: scheduleId,
          role: schedule.participantRole!.toLowerCase(),
        );
      }
      
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<ActivityEntity>> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  ) async {
    // Fast-path: avoid awaiting connectivity checks which can block for ~5s on some devices
    final t0 = DateTime.now();
    try {
      final activitiesResponse = await _remoteDataSource.getActivitiesBySchedule(
        scheduleId,
        date,
      );
      final t1 = DateTime.now();
      // ignore: avoid_print
      print('[TIMING][Repo] activities remote finished in ${t1.difference(t0).inMilliseconds}ms');

      if (activitiesResponse.participantRole.isNotEmpty) {
        // ignore: unawaited_futures
        UserStorage.setScheduleRole(
          scheduleId: scheduleId,
          role: activitiesResponse.participantRole.toLowerCase(),
        );
      }
      final filtered = activitiesResponse.responses
          .where((activity) => !activity.isDeleted)
          .toList();
      final t2 = DateTime.now();
      print('[TIMING][Repo] filter+prep in ${t2.difference(t1).inMilliseconds}ms (items=${filtered.length})');
      return filtered;
    } catch (e) {
      // Map to network failure only when clearly offline; otherwise treat as server failure
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<String> shareSchedule(String scheduleId) async {
    try {
      final response = await _remoteDataSource.shareSchedule(scheduleId);
      return response.sharedCode;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ScheduleEntity> createSchedule(CreateScheduleRequest request) async {
    try {
      final schedule = await _remoteDataSource.createSchedule(request);
      return schedule;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ScheduleEntity> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  ) async {
    try {
      final schedule = await _remoteDataSource.updateSchedule(
        scheduleId,
        request,
      );
      return schedule;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ActivityEntity> addActivity(CreateActivityRequest request) async {
    try {
      final activity = await _remoteDataSource.addActivity(request);
      return activity;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<ActivityEntity> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  ) async {
    try {
      final activity = await _remoteDataSource.updateActivity(
        activityId,
        request,
      );
      return activity;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteActivity(int activityId) async {
    try {
      await _remoteDataSource.deleteActivity(activityId);
      return;
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<Either<Failure, JoinScheduleResponse>> joinSchedule(JoinScheduleRequest request) async {
    try {
      final response = await _remoteDataSource.joinSchedule(request);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParticipantEntity>>> getScheduleParticipants(String scheduleId) async {
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
  }

  @override
  Future<Either<Failure, AddParticipantByEmailResponse>> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request) async {
    try {
      final response = await _remoteDataSource.addParticipantByEmail(scheduleId, request);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KickParticipantResult>> kickParticipant(String scheduleId, String participantId) async {
    try {
      final response = await _remoteDataSource.kickParticipant(scheduleId, participantId);
      final entities = response.scheduleParticipantResponses
          .map((m) {
            return ParticipantEntity(userId: m.userId, name: m.name, role: m.role, status: m.status);
          })
          .toList();
      
      // Calculate active participants count from entities
      final activeParticipantsCount = entities
          .where((participant) => participant.status == 'Active')
          .length;
      
      final result = KickParticipantResult(
        participantCounts: activeParticipantsCount, // Use calculated active count
        scheduleParticipantResponses: entities,
      );
      
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, KickParticipantResult>> leaveSchedule(String scheduleId, String userId) async {
    try {
      final response = await _remoteDataSource.leaveSchedule(scheduleId, userId);
      final entities = response.scheduleParticipantResponses
          .map((m) {
            return ParticipantEntity(userId: m.userId, name: m.name, role: m.role, status: m.status);
          })
          .toList();

      final activeParticipantsCount = entities
          .where((participant) => participant.status == 'Active')
          .length;

      final result = KickParticipantResult(
        participantCounts: activeParticipantsCount,
        scheduleParticipantResponses: entities,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changeParticipantRole(String scheduleId, String participantId) async {
    try {
      await _remoteDataSource.changeParticipantRole(scheduleId, participantId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reorderActivity({required int newIndex, required int activityId}) async {
    try {
      await _remoteDataSource.reorderActivity(newIndex: newIndex, activityId: activityId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CheckedItemEntity>>> getCheckedItems(String scheduleId) async {
    try {
      final checkedItems = await _remoteDataSource.getCheckedItems(scheduleId);
      final entities = checkedItems
          .where((item) => !item.isDeleted) // Filter out deleted items
          .map((model) => CheckedItemEntity(
                checkedItemId: model.checkedItemId,
                checkedItemName: model.checkedItemName,
                isChecked: model.isChecked,
                checkedAt: model.checkedAt,
                isDeleted: model.isDeleted,
                scheduleParticipantId: model.scheduleParticipantId,
              ))
          .toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AddCheckedItemResponse>>> addCheckedItem(List<AddCheckedItemRequest> request) async {
    try {
      final response = await _remoteDataSource.addCheckedItem(request);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckedItemEntity>> toggleCheckedItem(int checkedItemId, bool isChecked) async {
    try {
      final model = await _remoteDataSource.toggleCheckedItem(checkedItemId, isChecked);
      final entity = CheckedItemEntity(
        checkedItemId: model.checkedItemId,
        checkedItemName: model.checkedItemName,
        isChecked: model.isChecked,
        checkedAt: model.checkedAt,
        isDeleted: model.isDeleted,
        scheduleParticipantId: model.scheduleParticipantId,
      );
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteCheckedItemsBulk(List<int> checkedItemIds) async {
    try {
      final response = await _remoteDataSource.deleteCheckedItemsBulk(checkedItemIds);
      return Right(response['message'] as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScheduleEntity>> cancelSchedule(String scheduleId) async {
    try {
      final schedule = await _remoteDataSource.cancelSchedule(scheduleId);
      return Right(schedule);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> restoreSchedule(String scheduleId) async {
    try {
      final response = await _remoteDataSource.restoreSchedule(scheduleId);
      return Right(response['message'] as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CheckInEntity>> checkInActivity(CheckInRequest request) async {
    try {
      final response = await _remoteDataSource.checkInActivity(request);
      final entity = CheckInEntity(
        id: response.id,
        checkInTime: response.checkInTime,
        checkOutTime: response.checkOutTime,
        status: response.status,
        activityId: response.activityId,
        participantId: response.participantId,
      );
      return Right(entity);
    } catch (e) {
      // Extract meaningful error message
      String errorMessage = e.toString();
      if (e.toString().startsWith('Exception: ')) {
        errorMessage = e.toString().substring(11); // Remove "Exception: " prefix
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, CheckInEntity>> checkOutActivity(CheckOutRequest request) async {
    try {
      final response = await _remoteDataSource.checkOutActivity(request);
      final entity = CheckInEntity(
        id: response.id,
        checkInTime: response.checkInTime,
        checkOutTime: response.checkOutTime,
        status: response.status,
        activityId: response.activityId,
        participantId: response.participantId,
      );
      return Right(entity);
    } catch (e) {
      // Extract meaningful error message
      String errorMessage = e.toString();
      if (e.toString().startsWith('Exception: ')) {
        errorMessage = e.toString().substring(11); // Remove "Exception: " prefix
      }
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<MediaEntity>>> getMediaByActivity(int activityId) async {
    try {
      final mediaList = await _remoteDataSource.getMediaByActivity(activityId);
      final entities = mediaList.map((model) => MediaEntity(
        id: model.id,
        mediaType: model.mediaType,
        url: model.url,
        description: model.description,
        uploadedAt: model.uploadedAt,
        participantId: model.participantId,
        uploadMethod: model.uploadMethod,
        scheduleId: model.scheduleId,
        activityId: model.activityId,
        participantName: model.participantName,
        participantAvatar: model.participantAvatar,
      )).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MediaEntity>> uploadMedia(UploadMediaRequest request) async {
    try {
      final model = await _remoteDataSource.uploadMedia(request);
      final entity = MediaEntity(
        id: model.id,
        mediaType: model.mediaType,
        url: model.url,
        description: model.description,
        uploadedAt: model.uploadedAt,
        participantId: model.participantId,
        uploadMethod: model.uploadMethod,
        scheduleId: model.scheduleId,
        activityId: model.activityId,
        participantName: model.participantName,
        participantAvatar: model.participantAvatar,
      );
      return Right(entity);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
