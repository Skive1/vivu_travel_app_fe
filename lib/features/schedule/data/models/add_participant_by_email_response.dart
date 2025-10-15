class AddParticipantByEmailResponse {
  final String id;
  final String userId;
  final int role;
  final String joinedAt;
  final int status;

  const AddParticipantByEmailResponse({
    required this.id,
    required this.userId,
    required this.role,
    required this.joinedAt,
    required this.status,
  });

  factory AddParticipantByEmailResponse.fromJson(Map<String, dynamic> json) {
    return AddParticipantByEmailResponse(
      id: json['id'] as String,
      userId: json['userId'] as String,
      role: json['role'] as int,
      joinedAt: json['joineddAt'] as String, // Note: API has typo 'joineddAt'
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'role': role,
      'joineddAt': joinedAt, // Note: API has typo 'joineddAt'
      'status': status,
    };
  }
}
