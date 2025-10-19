class ParticipantModel {
  final String userId;
  final String name;
  final String role; // e.g., Owner, Viewer
  final String status; // e.g., Active, Banned

  ParticipantModel({
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    
    try {
      final userId = json['userId'] as String?;
      final name = json['name'] as String?;
      final roleValue = json['role'];
      final statusValue = json['status'];
      
      if (userId == null) {
        throw Exception('userId is null');
      }
      // name can be null for kick participant response
      final finalName = name ?? 'Unknown User';
      
      // Handle role - can be String or int
      String roleString = 'Unknown';
      if (roleValue != null) {
        if (roleValue is String) {
          // API returns String directly
          roleString = roleValue;
        } else if (roleValue is int) {
          // API returns int, convert to String
          switch (roleValue) {
            case 0:
              roleString = 'Owner';
              break;
            case 1:
              roleString = 'Viewer';
              break;
            case 2:
              roleString = 'Editor';
              break;
            default:
              roleString = 'Unknown';
          }
        }
      }
      
      // Handle status - can be String or int
      String statusString = 'Unknown';
      if (statusValue != null) {
        if (statusValue is String) {
          // API returns String directly
          statusString = statusValue;
        } else if (statusValue is int) {
          // API returns int, convert to String
          switch (statusValue) {
            case 0:
              statusString = 'Active';
              break;
            case 1:
              statusString = 'Left';
              break;
            case 2:
              statusString = 'Banned';
              break;
            default:
              statusString = 'Unknown';
          }
        }
      }
      
      return ParticipantModel(
        userId: userId,
        name: finalName,
        role: roleString,
        status: statusString,
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
      'status': status,
    };
  }
}
