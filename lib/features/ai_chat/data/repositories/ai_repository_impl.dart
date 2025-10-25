import '../../../../core/network/network_info.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/ai_request_entity.dart';
import '../../domain/entities/ai_response_entity.dart';
import '../../domain/entities/activity_request_entity.dart';
import '../../domain/entities/activity_response_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';
import '../models/ai_request_model.dart';
import '../models/activity_request_model.dart';

class AIRepositoryImpl implements AIRepository {
  final AIRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AIRepositoryImpl({
    required AIRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<AIResponseEntity> sendMessage(AIRequestEntity request) async {
    if (await _networkInfo.isConnected) {
      try {
        final requestModel = AIRequestModel.fromEntity(request);
        final responseModel = await _remoteDataSource.sendMessage(requestModel);
        return responseModel;
      } on ServerException catch (e) {
        throw ServerFailure(e.message);
      }
    } else {
      throw const NetworkFailure('No internet connection');
    }
  }

  @override
  Future<List<ActivityResponseEntity>> addListActivities(List<ActivityRequestEntity> activities) async {
    print('🟡 [DEBUG] AIRepositoryImpl.addListActivities called');
    print('🟡 [DEBUG] Activities count: ${activities.length}');
    
    if (await _networkInfo.isConnected) {
      print('🟡 [DEBUG] Network is connected, proceeding with API call');
      try {
        final activityModels = activities.map((activity) => ActivityRequestModel.fromEntity(activity)).toList();
        print('🟡 [DEBUG] Converted to models, calling remote data source');
        
        final responseModels = await _remoteDataSource.addListActivities(activityModels);
        print('🟡 [DEBUG] Remote data source returned ${responseModels.length} activities');
        
        return responseModels;
      } on ServerException catch (e) {
        print('🔴 [DEBUG] ServerException in repository: ${e.message}');
        throw ServerFailure(e.message);
      }
    } else {
      print('🔴 [DEBUG] No internet connection');
      throw const NetworkFailure('No internet connection');
    }
  }
}
