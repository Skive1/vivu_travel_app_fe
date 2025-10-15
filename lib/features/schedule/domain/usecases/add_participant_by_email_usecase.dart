import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/schedule_repository.dart';
import '../../data/models/add_participant_by_email_request.dart';
import '../../data/models/add_participant_by_email_response.dart';

class AddParticipantByEmail implements UseCase<AddParticipantByEmailResponse, AddParticipantByEmailParams> {
  final ScheduleRepository repository;

  AddParticipantByEmail(this.repository);

  @override
  Future<Either<Failure, AddParticipantByEmailResponse>> call(AddParticipantByEmailParams params) async {
    return await repository.addParticipantByEmail(
      params.scheduleId,
      params.request,
    );
  }
}

class AddParticipantByEmailParams {
  final String scheduleId;
  final AddParticipantByEmailRequest request;

  AddParticipantByEmailParams({
    required this.scheduleId,
    required this.request,
  });
}
