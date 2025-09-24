import 'package:equatable/equatable.dart';

class ResetTokenEntity extends Equatable {
  final String resetToken;
  final String email;

  const ResetTokenEntity({
    required this.resetToken,
    required this.email,
  });

  @override
  List<Object> get props => [resetToken, email];
}
