import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UpdateUserProfileRequested extends UserEvent {
  final String dateOfBirth;
  final String address;
  final String name;
  final String phoneNumber;
  final String gender;
  final String? avatarFilePath;

  const UpdateUserProfileRequested({
    required this.dateOfBirth,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    this.avatarFilePath,
  });

  @override
  List<Object?> get props => [dateOfBirth, address, name, phoneNumber, gender, avatarFilePath ?? ''];
}


