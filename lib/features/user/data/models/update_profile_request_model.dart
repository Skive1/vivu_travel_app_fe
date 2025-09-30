import 'package:dio/dio.dart';

class UpdateProfileRequestModel {
  final String dateOfBirth;
  final String address;
  final String name;
  final String phoneNumber;
  final String gender;
  final MultipartFile? avatarFile;

  UpdateProfileRequestModel({
    required this.dateOfBirth,
    required this.address,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    this.avatarFile,
  });

  FormData toFormData() {
    final map = <String, dynamic>{
      'DateOfBirth': dateOfBirth,
      'Address': address,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'Gender': gender,
    };

    if (avatarFile != null) {
      map['AvatarUrl'] = avatarFile;
    }

    return FormData.fromMap(map);
  }
}


