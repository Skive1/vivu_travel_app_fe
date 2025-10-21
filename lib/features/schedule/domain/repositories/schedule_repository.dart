import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/schedule_entity.dart';
import '../entities/activity_entity.dart';
import '../entities/kick_participant_result.dart';
import '../../data/models/create_schedule_request.dart';
import '../../data/models/update_schedule_request.dart';
import '../../data/models/create_activity_request.dart';
import '../../data/models/update_activity_request.dart';
import '../../data/models/join_schedule_request.dart';
import '../../data/models/join_schedule_response.dart';
import '../../data/models/add_participant_by_email_request.dart';
import '../../data/models/add_participant_by_email_response.dart';
import '../entities/participant_entity.dart';
import '../entities/checked_item_entity.dart';
import '../../data/models/add_checked_item_request.dart';
import '../../data/models/add_checked_item_response.dart';
import '../entities/checkin_entity.dart';
import '../entities/media_entity.dart';
import '../../data/models/checkin_request.dart';
import '../../data/models/checkout_request.dart';
import '../../data/models/upload_media_request.dart';
import '../../data/models/mapbox_geocoding_response.dart';

abstract class ScheduleRepository {
  Future<List<ScheduleEntity>> getSchedulesByParticipant(String participantId);
  Future<Either<Failure, ScheduleEntity>> getScheduleById(String scheduleId);
  Future<List<ActivityEntity>> getActivitiesBySchedule(
    String scheduleId,
    DateTime date,
  );
  Future<String> shareSchedule(String scheduleId);
  Future<ScheduleEntity> createSchedule(CreateScheduleRequest request);
  Future<ScheduleEntity> updateSchedule(
    String scheduleId,
    UpdateScheduleRequest request,
  );
  Future<Either<Failure, ScheduleEntity>> cancelSchedule(String scheduleId);
  Future<Either<Failure, String>> restoreSchedule(String scheduleId);
  Future<ActivityEntity> addActivity(CreateActivityRequest request);
  Future<ActivityEntity> updateActivity(
    int activityId,
    UpdateActivityRequest request,
  );
  Future<void> deleteActivity(int activityId);
  Future<Either<Failure, JoinScheduleResponse>> joinSchedule(JoinScheduleRequest request);
  Future<Either<Failure, List<ParticipantEntity>>> getScheduleParticipants(String scheduleId);
  Future<Either<Failure, AddParticipantByEmailResponse>> addParticipantByEmail(String scheduleId, AddParticipantByEmailRequest request);
  Future<Either<Failure, KickParticipantResult>> kickParticipant(String scheduleId, String participantId);
  Future<Either<Failure, KickParticipantResult>> leaveSchedule(String scheduleId, String userId);
  Future<Either<Failure, Unit>> changeParticipantRole(String scheduleId, String participantId);
  Future<Either<Failure, Unit>> reorderActivity({required int newIndex, required int activityId});
  
  // Checked items methods
  Future<Either<Failure, List<CheckedItemEntity>>> getCheckedItems(String scheduleId);
  Future<Either<Failure, List<AddCheckedItemResponse>>> addCheckedItem(List<AddCheckedItemRequest> request);
  Future<Either<Failure, CheckedItemEntity>> toggleCheckedItem(int checkedItemId, bool isChecked);
  Future<Either<Failure, String>> deleteCheckedItemsBulk(List<int> checkedItemIds);
  
  // Check-in/Check-out methods
  Future<Either<Failure, CheckInEntity>> checkInActivity(CheckInRequest request);
  Future<Either<Failure, CheckInEntity>> checkOutActivity(CheckOutRequest request);
  
  // Media methods
  Future<Either<Failure, List<MediaEntity>>> getMediaByActivity(int activityId);
  Future<Either<Failure, MediaEntity>> uploadMedia(UploadMediaRequest request);
  
  // Mapbox geocoding methods
  Future<Either<Failure, MapboxGeocodingResponse>> searchAddress(String query);
  Future<Either<Failure, MapboxGeocodingResponse>> searchAddressStructured({
    String? addressNumber,
    String? street,
    String? locality,
    String? region,
    String? country,
  });
}
