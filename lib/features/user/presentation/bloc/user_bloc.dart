import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/user_storage.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UpdateProfileUseCase updateProfileUseCase;

  UserBloc({required this.updateProfileUseCase}) : super(UserInitial()) {
    on<UpdateUserProfileRequested>(_onUpdateUserProfileRequested);
  }

  Future<void> _onUpdateUserProfileRequested(
    UpdateUserProfileRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());

    final result = await updateProfileUseCase(UpdateProfileParams(
      dateOfBirth: event.dateOfBirth,
      address: event.address,
      name: event.name,
      phoneNumber: event.phoneNumber,
      gender: event.gender,
      avatarFilePath: event.avatarFilePath,
    ));

    await result.fold(
      (failure) async {
        if (!emit.isDone) emit(UserError(failure.message));
      },
      (updatedUser) async {
        await UserStorage.saveUserProfile(updatedUser);
        if (!emit.isDone) emit(UserUpdateSuccess('Profile updated successfully'));
      },
    );
  }
}


