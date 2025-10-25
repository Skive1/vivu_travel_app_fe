import '../entities/ai_request_entity.dart';
import '../entities/ai_response_entity.dart';
import '../entities/activity_request_entity.dart';
import '../entities/activity_response_entity.dart';

abstract class AIRepository {
  Future<AIResponseEntity> sendMessage(AIRequestEntity request);
  Future<List<ActivityResponseEntity>> addListActivities(List<ActivityRequestEntity> activities);
}
