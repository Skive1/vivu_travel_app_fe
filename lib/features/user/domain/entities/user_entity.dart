import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final DateTime? createdAt;
  final bool isActive;
  final String roleName;
  final String dateOfBirth;
  final String address;
  final String phoneNumber;
  final String gender;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.createdAt,
    required this.isActive,
    required this.roleName,
    required this.dateOfBirth,
    required this.address,
    required this.phoneNumber,
    required this.gender,
  });

  // Helper methods for UI
  String get displayName => name.isNotEmpty ? name : email;
  
  String get avatarInitials {
    if (name.isNotEmpty) {
      final words = name.split(' ');
      if (words.length >= 2) {
        return '${words[0][0]}${words[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  bool get hasValidAvatar {
    return avatar != null && 
           avatar!.isNotEmpty && 
           avatar!.startsWith('http') &&
           !avatar!.contains('string'); // Check for default "string" value
  }

  @override
  List<Object?> get props => [
    id, email, name, avatar, createdAt, isActive, 
    roleName, dateOfBirth, address, phoneNumber, gender
  ];
}
