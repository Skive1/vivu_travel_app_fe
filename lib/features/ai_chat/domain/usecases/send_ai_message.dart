import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ai_request_entity.dart';
import '../entities/ai_response_entity.dart';
import '../repositories/ai_repository.dart';

class SendAIMessage implements UseCase<AIResponseEntity, AIRequestEntity> {
  final AIRepository _repository;

  SendAIMessage({required AIRepository repository}) : _repository = repository;

  @override
  Future<Either<Failure, AIResponseEntity>> call(AIRequestEntity params) async {
    try {
      final result = await _repository.sendMessage(params);
      return Right(result);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      } else {
        return Left(ServerFailure(e.toString()));
      }
    }
  }
}
