import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checked_item_entity.dart';
import '../repositories/schedule_repository.dart';

class GetCheckedItemsUseCase implements UseCase<List<CheckedItemEntity>, GetCheckedItemsParams> {
  final ScheduleRepository repository;

  GetCheckedItemsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<CheckedItemEntity>>> call(GetCheckedItemsParams params) async {
    return await repository.getCheckedItems(params.scheduleId);
  }
}

class GetCheckedItemsParams {
  final String scheduleId;

  GetCheckedItemsParams({required this.scheduleId});
}
