class AddParticipantByEmailRequest {
  final String email;

  const AddParticipantByEmailRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory AddParticipantByEmailRequest.fromJson(Map<String, dynamic> json) {
    return AddParticipantByEmailRequest(
      email: json['email'] as String,
    );
  }
}
