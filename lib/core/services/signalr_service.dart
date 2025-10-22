import 'dart:async';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';
import '../constants/app_config.dart';

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
      log('🔌 Initializing SignalR connection to: ${AppConfig.signalRUrl}');

      _connection = HubConnectionBuilder()
          .withUrl(
            AppConfig.signalRUrl,
            options: HttpConnectionOptions(
              logMessageContent: true,
              transport: HttpTransportType.ServerSentEvents,
              skipNegotiation: false,
            ),
          )
          .withAutomaticReconnect()
          .build();

      log('🔧 SignalR HubConnectionBuilder created');

      // Setup connection event handlers
      _setupConnectionHandlers();
      log('🔧 Connection handlers setup completed');

      // Setup notification handler - handle JsonElement like backend
      _connection!.on('ReceiveNotification', _handleNotification);
      log('🔧 Notification handler setup completed');

      log('✅ SignalR connection initialized successfully');
    } catch (e) {
      log('❌ Failed to initialize SignalR connection: $e');
      rethrow;
    }
  }

  /// Start the connection
  Future<void> start() async {
    if (_connection == null) {
      await initialize();
    }

    if (_isConnected) {
      log('⚠️ SignalR already connected');
      return;
    }

    try {
      log('🚀 Starting SignalR connection to: ${AppConfig.signalRUrl}');
      log('🔧 Connection state before start: ${_connection?.state}');
      await _connection!.start();
      _isConnected = true;
      _connectionStateController.add(SignalRConnectionState.connected);
      log('✅ SignalR connection started successfully');
    } catch (e) {
      log('❌ Failed to start SignalR connection: $e');
      log('🔧 Connection state after error: ${_connection?.state}');
      _connectionStateController.add(SignalRConnectionState.disconnected);
      rethrow;
    }
  }

  /// Stop the connection
  Future<void> stop() async {
    if (!_isConnected || _connection == null) {
      log('⚠️ SignalR not connected');
      return;
    }

    try {
      log('🛑 Stopping SignalR connection...');
      await _connection!.stop();
      _isConnected = false;
      _currentUserId = null;
      _joinedGroups.clear();
      _connectionStateController.add(SignalRConnectionState.disconnected);
      log('✅ SignalR connection stopped successfully');
    } catch (e) {
      log('❌ Error stopping SignalR connection: $e');
    }
  }

  /// Join user group for personal notifications
  Future<void> joinUserGroup(String userId) async {
    if (!_isConnected || _connection == null) {
      log('❌ Cannot join user group: SignalR not connected');
      return;
    }

    try {
      log('👤 Joining user group: $userId');
      await _connection!.invoke('JoinUser', args: [userId]);
      _currentUserId = userId;
      if (!_joinedGroups.contains(userId)) {
        _joinedGroups.add(userId);
      }
      log('✅ Successfully joined user group: $userId');
    } catch (e) {
      log('❌ Failed to join user group $userId: $e');
      rethrow;
    }
  }

  /// Join schedule group for schedule notifications
  Future<void> joinScheduleGroup(String scheduleId) async {
    if (!_isConnected || _connection == null) {
      log('❌ Cannot join schedule group: SignalR not connected');
      return;
    }

    try {
      log('📅 Joining schedule group: $scheduleId');
      await _connection!.invoke('JoinSchedule', args: [scheduleId]);
      if (!_joinedGroups.contains(scheduleId)) {
        _joinedGroups.add(scheduleId);
      }
      log('✅ Successfully joined schedule group: $scheduleId');
    } catch (e) {
      log('❌ Failed to join schedule group $scheduleId: $e');
      rethrow;
    }
  }

  /// Leave a group
  Future<void> leaveGroup(String groupId) async {
    if (!_isConnected || _connection == null) {
      log('❌ Cannot leave group: SignalR not connected');
      return;
    }

    try {
      log('🚪 Leaving group: $groupId');
      await _connection!.invoke('LeaveGroup', args: [groupId]);
      _joinedGroups.remove(groupId);
      log('✅ Successfully left group: $groupId');
    } catch (e) {
      log('❌ Failed to leave group $groupId: $e');
      rethrow;
    }
  }

  /// Setup connection event handlers
  void _setupConnectionHandlers() {
    _connection!.onclose(({Exception? error}) {
      log('🔌 SignalR connection closed: ${error?.toString() ?? 'No error'}');
      _isConnected = false;
      _connectionStateController.add(SignalRConnectionState.disconnected);
    });

    _connection!.onreconnecting(({Exception? error}) {
      log('🔄 SignalR reconnecting: ${error?.toString() ?? 'No error'}');
      _connectionStateController.add(SignalRConnectionState.reconnecting);
    });

    _connection!.onreconnected(({String? connectionId}) {
      log('✅ SignalR reconnected with connection ID: $connectionId');
      _isConnected = true;
      _connectionStateController.add(SignalRConnectionState.connected);

      // Rejoin groups after reconnection
      _rejoinGroups();
    });
  }

  /// Handle incoming notifications
  void _handleNotification(List<Object?>? args) {
    try {
      if (args != null && args.isNotEmpty) {
        // Handle JsonElement like backend demo
        final notification = args.first;
        log('📨 Received notification: $notification');

        // Convert to Map<String, dynamic> for compatibility
        Map<String, dynamic> notificationMap;
        if (notification is Map<String, dynamic>) {
          notificationMap = notification;
        } else {
          // If it's JsonElement or other type, convert to string first
          notificationMap = {
            'data': notification.toString(),
            'timestamp': DateTime.now().toIso8601String(),
          };
        }

        _notificationController.add(notificationMap);
      }
    } catch (e) {
      log('❌ Error handling notification: $e');
    }
  }

  /// Rejoin all groups after reconnection
  Future<void> _rejoinGroups() async {
    if (_currentUserId != null) {
      await joinUserGroup(_currentUserId!);
    }

    for (final groupId in _joinedGroups) {
      if (groupId != _currentUserId) {
        await joinScheduleGroup(groupId);
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _connectionStateController.close();
    _connection?.stop();
    _connection = null;
    _isConnected = false;
    _currentUserId = null;
    _joinedGroups.clear();
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
