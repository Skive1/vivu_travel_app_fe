import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/add_checked_item_request.dart';
import '../../data/models/add_checked_item_response.dart';
import '../repositories/schedule_repository.dart';

class AddCheckedItemUseCase implements UseCase<List<AddCheckedItemResponse>, AddCheckedItemParams> {
  final ScheduleRepository repository;

  AddCheckedItemUseCase({required this.repository});

  @override
  Future<Either<Failure, List<AddCheckedItemResponse>>> call(AddCheckedItemParams params) async {
    return await repository.addCheckedItem(params.request);
  }
}

class AddCheckedItemParams {
  final List<AddCheckedItemRequest> request;

  AddCheckedItemParams({required this.request});
}
