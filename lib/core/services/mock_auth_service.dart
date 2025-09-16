import '../../features/authentication/domain/entities/user_entity.dart';

class MockAuthService {
  // Mock users database
  static const List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'email': 'admin@vivu.com',
      'password': '123456',
      'name': 'Admin Vivu',
      'avatar': 'https://ui-avatars.com/api/?name=Admin+Vivu&background=2E86AB&color=fff',
    },
    {
      'id': '2', 
      'email': 'john@gmail.com',
      'password': 'password',
      'name': 'John Doe',
      'avatar': 'https://ui-avatars.com/api/?name=John+Doe&background=4ECDC4&color=fff',
    },
    {
      'id': '3',
      'email': 'mary@gmail.com', 
      'password': '123456',
      'name': 'Mary Johnson',
      'avatar': 'https://ui-avatars.com/api/?name=Mary+Johnson&background=F24236&color=fff',
    },
    {
      'id': '4',
      'email': 'david@outlook.com',
      'password': 'password123',
      'name': 'David Wilson',
      'avatar': 'https://ui-avatars.com/api/?name=David+Wilson&background=F6AE2D&color=fff',
    },
    {
      'id': '5',
      'email': 'test@test.com',
      'password': 'test',
      'name': 'Test User',
      'avatar': 'https://ui-avatars.com/api/?name=Test+User&background=AB47BC&color=fff',
    },
  ];

  // Simulate network delay
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  // Mock login method
  static Future<AuthResult> login(String email, String password) async {
    await _simulateNetworkDelay();

    try {
      // Find user by email
      final userData = _mockUsers.firstWhere(
        (user) => user['email'].toString().toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // Check password
      if (userData['password'] != password) {
        return AuthResult.failure('Mật khẩu không đúng');
      }

      // Create user entity
      final user = UserEntity(
        id: userData['id'],
        email: userData['email'],
        name: userData['name'],
        avatar: userData['avatar'],
        createdAt: DateTime.now(),
      );

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.failure('Email không tồn tại trong hệ thống');
    }
  }

  // Mock register method
  static Future<AuthResult> register({
    required String email,
    required String password,
    required String name,
  }) async {
    await _simulateNetworkDelay();

    try {
      // Check if email already exists
      final existingUser = _mockUsers.where(
        (user) => user['email'].toString().toLowerCase() == email.toLowerCase(),
      );

      if (existingUser.isNotEmpty) {
        return AuthResult.failure('Email đã được sử dụng');
      }

      // Create new user (in real app, this would save to database)
      final newUser = UserEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name,
        avatar: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(name)}&background=2E86AB&color=fff',
        createdAt: DateTime.now(),
      );

      return AuthResult.success(newUser);
    } catch (e) {
      return AuthResult.failure('Đăng ký thất bại. Vui lòng thử lại.');
    }
  }

  // Get demo accounts for testing
  static List<Map<String, String>> getDemoAccounts() {
    return _mockUsers.map((user) => {
      'email': user['email'] as String,
      'password': user['password'] as String,
      'name': user['name'] as String,
    }).toList();
  }
}

// Auth result class
class AuthResult {
  final bool isSuccess;
  final UserEntity? user;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
  });

  factory AuthResult.success(UserEntity user) {
    return AuthResult._(
      isSuccess: true,
      user: user,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
