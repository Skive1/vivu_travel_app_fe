class ParticipantEntity {
  final String userId;
  final String name;
  final String role; // Owner, Viewer
  final String status; // Active, Banned

  ParticipantEntity({
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
  });
}
