import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/activity_request_entity.dart';
import '../entities/activity_response_entity.dart';
import '../repositories/ai_repository.dart';

class AddListActivities implements UseCase<List<ActivityResponseEntity>, List<ActivityRequestEntity>> {
  final AIRepository _repository;

  AddListActivities({required AIRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, List<ActivityResponseEntity>>> call(List<ActivityRequestEntity> params) async {
    print('🟠 [DEBUG] AddListActivities use case called');
    print('🟠 [DEBUG] Params count: ${params.length}');
    
    try {
      print('🟠 [DEBUG] Calling repository.addListActivities');
      final result = await _repository.addListActivities(params);
      print('🟠 [DEBUG] Repository returned ${result.length} activities');
      print('🟠 [DEBUG] Returning Right(result)');
      return Right(result);
    } catch (e) {
      print('🔴 [DEBUG] Exception in AddListActivities use case: $e');
      if (e is Failure) {
        print('🔴 [DEBUG] Exception is Failure, returning Left(e)');
        return Left(e);
      } else {
        print('🔴 [DEBUG] Exception is not Failure, wrapping in ServerFailure');
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
