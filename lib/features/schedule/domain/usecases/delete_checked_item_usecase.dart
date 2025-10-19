import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';

class DeleteCheckedItemsBulkUseCase implements UseCase<String, DeleteCheckedItemsBulkParams> {
  final ScheduleRepository repository;

  DeleteCheckedItemsBulkUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(DeleteCheckedItemsBulkParams params) async {
    return await repository.deleteCheckedItemsBulk(params.checkedItemIds);
  }
}

class DeleteCheckedItemsBulkParams {
  final List<int> checkedItemIds;

  DeleteCheckedItemsBulkParams({required this.checkedItemIds});
}
