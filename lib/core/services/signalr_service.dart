import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/app_config.dart';
import 'local_notification_service.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _connection;
  bool _isConnected = false;
  String? _currentUserId;
  List<String> _joinedGroups = [];

  // Stream controllers for real-time notifications
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<SignalRConnectionState> _connectionStateController =
      StreamController<SignalRConnectionState>.broadcast();
  final LocalNotificationService _localNotificationService = LocalNotificationService();

  // Getters
  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;
  List<String> get joinedGroups => List.unmodifiable(_joinedGroups);

  // Streams
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<SignalRConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Initialize SignalR connection
  Future<void> initialize() async {
    try {

      _connection = HubConnectionBuilder()
          .withUrl(
            AppConfig.signalRUrl,
            options: HttpConnectionOptions(
              logMessageContent: true,
              transport: HttpTransportType.WebSockets,
              skipNegotiation: false,
            ),
          )
          .withAutomaticReconnect()
          .build();


      // Setup connection event handlers
      _setupConnectionHandlers();

      // Setup notification handlers for different possible method names
      _connection!.on('ReceiveNotification', _handleNotification);
      _connection!.on('SendNotification', _handleNotification);
      _connection!.on('Notification', _handleNotification);
      _connection!.on('Message', _handleNotification);
      _connection!.on('Update', _handleNotification);
      _connection!.on('ScheduleUpdate', _handleNotification);
      _connection!.on('ScheduleNotification', _handleNotification);
      
      // Add a generic handler to catch any method calls
      _connection!.on('*', _handleGenericNotification);

    } catch (e) {
      log('❌ Failed to initialize SignalR connection: $e');
      rethrow;
    }
  }

  /// Start the connection with retry mechanism
  Future<void> start() async {
    if (_connection == null) {
      await initialize();
    }

    if (_isConnected) {
      return;
    }

    const maxRetries = 3;
    const retryDelays = [Duration(seconds: 1), Duration(seconds: 3), Duration(seconds: 5)];
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        
        // Add connection timeout
        final connection = _connection!;
        try {
          await connection.start();
        } catch (e) {
          if (e.toString().contains('timeout')) {
            throw TimeoutException('SignalR connection timeout after 30 seconds', const Duration(seconds: 30));
          }
          rethrow;
        }
        
        _isConnected = true;
        _connectionStateController.add(SignalRConnectionState.connected);
        return; // Success, exit retry loop
        
      } catch (e) {
        
        // Add specific error handling
        if (e is TimeoutException) {
        } else if (e.toString().contains('timeout')) {
        } else if (e.toString().contains('connection refused')) {
        }
        
        // If this is the last attempt, throw the error
        if (attempt == maxRetries - 1) {
          _connectionStateController.add(SignalRConnectionState.error);
          rethrow;
        }
        
        // Wait before retrying with exponential backoff
        final delay = retryDelays[attempt];
        await Future.delayed(delay);
      }
    }
  }

  /// Stop the connection
  Future<void> stop() async {
    if (!_isConnected || _connection == null) {
      return;
    }

    try {
      await _connection!.stop();
      _isConnected = false;
      _currentUserId = null;
      _joinedGroups.clear(); // Clear schedule groups
      _connectionStateController.add(SignalRConnectionState.disconnected);
    } catch (e) {
      log('❌ Error stopping SignalR connection: $e');
    }
  }

  /// Join user group for personal notifications
  Future<void> joinUserGroup(String userId) async {
    // Validate userId before proceeding
    if (userId.isEmpty) {
      log('❌ Cannot join user group: userId is empty');
      return;
    }
    
    if (!_isConnected || _connection == null) {
      log('❌ Cannot join user group: SignalR is not connected');
      return;
    }

    try {
      log('🔄 Joining user group: $userId');
      await _connection!.invoke('JoinUser', args: [userId]);
      _currentUserId = userId;
      log('✅ Successfully joined user group: $userId');
      // Note: User ID is not added to _joinedGroups as it only contains schedule IDs
    } catch (e) {
      log('❌ Failed to join user group $userId: $e');
      rethrow; // Re-throw to let caller handle the error
    }
  }

  /// Join schedule group for schedule notifications
  Future<void> joinScheduleGroup(String scheduleId) async {
    // Validate scheduleId before proceeding
    if (scheduleId.isEmpty) {
      log('❌ Cannot join schedule group: scheduleId is empty');
      return;
    }
    
    if (!_isConnected || _connection == null) {
      log('❌ Cannot join schedule group: SignalR is not connected');
      return;
    }

    try {
      log('🔄 Joining schedule group: $scheduleId');
      await _connection!.invoke('JoinSchedule', args: [scheduleId]);
      if (!_joinedGroups.contains(scheduleId)) {
        _joinedGroups.add(scheduleId);
        log('✅ Successfully joined schedule group: $scheduleId');
      } else {
        log('⚠️ Schedule group $scheduleId already joined');
      }
    } catch (e) {
      log('❌ Failed to join schedule group $scheduleId: $e');
      rethrow; // Re-throw to let caller handle the error
    }
  }

  /// Leave a schedule group
  Future<void> leaveGroup(String scheduleId) async {
    if (!_isConnected || _connection == null) {
      return;
    }

    try {
      await _connection!.invoke('LeaveGroup', args: [scheduleId]);
      _joinedGroups.remove(scheduleId);
    } catch (e) {
      log('❌ Failed to leave schedule group $scheduleId: $e');
      rethrow;
    }
  }

  /// Setup connection event handlers
  void _setupConnectionHandlers() {
    _connection!.onclose(({Exception? error}) {
      _isConnected = false;
      _connectionStateController.add(SignalRConnectionState.disconnected);
      
      // Log specific close reasons
      if (error != null) {
        if (error.toString().contains('timeout')) {
        } else if (error.toString().contains('connection refused')) {
        } else if (error.toString().contains('network')) {
        }
      }
    });

    _connection!.onreconnecting(({Exception? error}) {
      _connectionStateController.add(SignalRConnectionState.reconnecting);
      
      // Log reconnection attempts
      if (error != null) {
      }
    });

    _connection!.onreconnected(({String? connectionId}) {
      _isConnected = true;
      _connectionStateController.add(SignalRConnectionState.connected);

      // Rejoin groups after reconnection
      _rejoinGroups();
    });
  }

  /// Handle generic notifications (catch-all)
  void _handleGenericNotification(List<Object?>? args) {
    if (args != null) {
      for (int i = 0; i < args.length; i++) {
      }
    }
    _handleNotification(args);
  }

  /// Handle incoming notifications
  void _handleNotification(List<Object?>? args) async {
    try {
      if (args != null && args.isNotEmpty) {
        final notification = args.first;

        // Convert to Map<String, dynamic> for compatibility
        Map<String, dynamic> notificationMap;
        if (notification is Map<String, dynamic>) {
          notificationMap = notification;
        } else {
          // Handle JsonElement or other types from backend
          try {
            final notificationString = notification.toString();
            
            // Try to parse as JSON if it looks like JSON
            if (notificationString.startsWith('{') && notificationString.endsWith('}')) {
              // Parse the JSON string properly
              final jsonData = jsonDecode(notificationString) as Map<String, dynamic>;
              notificationMap = jsonData;
            } else {
              // Fallback for non-JSON data
              notificationMap = {
                'data': notificationString,
                'timestamp': DateTime.now().toIso8601String(),
                'type': 'SignalRNotification'
              };
            }
          } catch (parseError) {
            notificationMap = {
              'data': notification.toString(),
              'timestamp': DateTime.now().toIso8601String(),
              'type': 'SignalRNotification',
              'parseError': parseError.toString()
            };
          }
        }

        // Add timestamp if not present
        if (!notificationMap.containsKey('timestamp')) {
          notificationMap['timestamp'] = DateTime.now().toIso8601String();
        }
        
        // Show popup notification immediately
        try {
          final title = notificationMap['title'] ?? 'Thông báo mới';
          final message = notificationMap['message'] ?? 'Bạn có thông báo mới';
          final scheduleName = notificationMap['scheduleName'] ?? '';
          final senderName = notificationMap['senderName'] ?? '';
          final type = notificationMap['type'] ?? '';
          final scheduleId = notificationMap['scheduleID'] ?? notificationMap['scheduleId'];
          
          if (type == 'ScheduleUpdated' && scheduleName.isNotEmpty) {
            await _localNotificationService.showScheduleUpdateNotification(
              scheduleName: scheduleName,
              message: message,
              senderName: senderName,
              scheduleId: scheduleId,
            );
          } else {
            await _localNotificationService.showGeneralNotification(
              title: title,
              message: message,
              type: type,
            );
          }
        } catch (e) {
          log('❌ Error showing popup notification: $e');
        }
        
        _notificationController.add(notificationMap);
      }
    } catch (e) {
      log('❌ Error handling notification: $e');
    }
  }

  /// Rejoin all groups after reconnection
  Future<void> _rejoinGroups() async {
    // Rejoin user group
    if (_currentUserId != null) {
      await joinUserGroup(_currentUserId!);
    }

    // Rejoin schedule groups (joinedGroups only contains schedule IDs)
    for (final scheduleId in _joinedGroups) {
      await joinScheduleGroup(scheduleId);
    }
  }


  /// Get connection diagnostics
  Map<String, dynamic> getConnectionDiagnostics() {
    return {
      'isConnected': _isConnected,
      'connectionState': _connection?.state?.toString() ?? 'null',
      'currentUserId': _currentUserId,
      'joinedGroups': _joinedGroups,
      'signalRUrl': AppConfig.signalRUrl,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }


  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _connectionStateController.close();
    _connection?.stop();
    _connection = null;
    _isConnected = false;
    _currentUserId = null;
    _joinedGroups.clear(); // Clear schedule groups
  }
}

/// SignalR connection states
enum SignalRConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}
