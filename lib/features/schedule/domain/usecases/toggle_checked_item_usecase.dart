import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/checked_item_entity.dart';
import '../repositories/schedule_repository.dart';

class ToggleCheckedItemUseCase implements UseCase<CheckedItemEntity, ToggleCheckedItemParams> {
  final ScheduleRepository repository;

  ToggleCheckedItemUseCase({required this.repository});

  @override
  Future<Either<Failure, CheckedItemEntity>> call(ToggleCheckedItemParams params) async {
    return await repository.toggleCheckedItem(params.checkedItemId, params.isChecked);
  }
}

class ToggleCheckedItemParams {
  final int checkedItemId;
  final bool isChecked;

  ToggleCheckedItemParams({required this.checkedItemId, required this.isChecked});
}
