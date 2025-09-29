class RegisterRequestModel {
  final String email;
  final String password;
  final String dateOfBirth;
  final String name;
  final String address;
  final String phoneNumber;
  final String gender;

  const RegisterRequestModel({
    required this.email,
    required this.password,
    required this.dateOfBirth,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'dateOfBirth': dateOfBirth,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'gender': gender,
    };
  }
}