import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_constants.dart';
import '../core/error/exceptions.dart';
import '../services/notification_service.dart';

/// WebSocket service provider
final websocketServiceProvider = StateNotifierProvider<WebSocketServiceNotifier, WebSocketState>(
  (ref) => WebSocketServiceNotifier(ref.read(notificationServiceProvider)),
);

/// WebSocket state
class WebSocketState {
  final bool isConnected;
  final bool isConnecting;
  final String? error;
  final List<WebSocketMessage> messages;
  
  WebSocketState({
    this.isConnected = false,
    this.isConnecting = false,
    this.error,
    this.messages = const [],
  });
  
  WebSocketState copyWith({
    bool? isConnected,
    bool? isConnecting,
    String? error,
    List<WebSocketMessage>? messages,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error,
      messages: messages ?? this.messages,
    );
  }
}

/// WebSocket message
class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  WebSocketMessage({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// WebSocket service notifier
class WebSocketServiceNotifier extends StateNotifier<WebSocketState> {
  WebSocketChannel? _channel;
  String? _userId;
  String? _token;
  final NotificationService _notificationService;
  
  WebSocketServiceNotifier(this._notificationService) : super(WebSocketState());
  
  Future<void> initialize({String? userId, String? token}) async {
    _userId = userId;
    _token = token;
    
    if (userId != null && token != null) {
      await connect();
    }
  }
  
  Future<void> connect() async {
    if (_userId == null || _token == null) {
      throw LocationException('User ID and token required for WebSocket connection');
    }
    
    state = state.copyWith(isConnecting: true, error: null);
    
    try {
      final wsUrl = Uri.parse('${ApiConstants.baseUrl.replaceFirst('http', 'ws')}/ws');
      _channel = WebSocketChannel.connect(
        wsUrl.replace(
          queryParameters: {
            'user_id': _userId,
            'token': _token,
          },
        ),
      );
      
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          state = state.copyWith(
            isConnected: false,
            isConnecting: false,
            error: error.toString(),
          );
        },
        onDone: () {
          state = state.copyWith(
            isConnected: false,
            isConnecting: false,
          );
          // Attempt reconnection
          Future.delayed(const Duration(seconds: 5), () => connect());
        },
      );
      
      state = state.copyWith(
        isConnected: true,
        isConnecting: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString(),
      );
    }
  }
  
  void _handleMessage(dynamic message) {
    try {
      final data = message as Map<String, dynamic>;
      final type = data['type'] as String;
      final payload = data['data'] as Map<String, dynamic>? ?? {};
      
      final wsMessage = WebSocketMessage(type: type, data: payload);
      
      // Add to message history
      state = state.copyWith(
        messages: [...state.messages, wsMessage],
      );
      
      // Handle specific message types
      _handleMessageByType(wsMessage);
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }
  
  void _handleMessageByType(WebSocketMessage message) {
    switch (message.type) {
      case 'new_incident':
        _handleNewIncident(message.data);
        break;
      case 'incident_updated':
        _handleIncidentUpdated(message.data);
        break;
      case 'circle_update':
        _handleCircleUpdate(message.data);
        break;
      case 'trust_score_changed':
        _handleTrustScoreChanged(message.data);
        break;
      case 'emergency_alert':
        _handleEmergencyAlert(message.data);
        break;
      case 'circle_invitation':
        _handleCircleInvitation(message.data);
        break;
      default:
        print('Unknown message type: ${message.type}');
    }
  }
  
  void _handleNewIncident(Map<String, dynamic> data) {
    final incidentId = data['incident_id'] as String;
    final severity = data['severity'] as String;
    final location = data['location'] as Map<String, dynamic>?;
    
    // Show notification
    _notificationService.showIncidentNotification(
      title: 'New Incident Nearby',
      body: 'A new incident has been reported in your area',
      payload: incidentId,
    );
  }
  
  void _handleIncidentUpdated(Map<String, dynamic> data) {
    final incidentId = data['incident_id'] as String;
    final status = data['status'] as String;
    
    if (status == 'approved') {
      _notificationService.showIncidentNotification(
        title: 'Incident Approved',
        body: 'Your incident report has been approved',
        payload: incidentId,
      );
    }
  }
  
  void _handleCircleUpdate(Map<String, dynamic> data) {
    final circleId = data['circle_id'] as String;
    final circleName = data['circle_name'] as String;
    final updateType = data['update_type'] as String;
    
    _notificationService.showCircleNotification(
      title: 'Circle Update',
      body: '$circleName: $updateType',
      payload: circleId,
    );
  }
  
  void _handleTrustScoreChanged(Map<String, dynamic> data) {
    final newScore = data['new_score'] as double;
    // Could show in-app notification or update UI
  }
  
  void _handleEmergencyAlert(Map<String, dynamic> data) {
    final alertType = data['alert_type'] as String;
    final message = data['message'] as String;
    
    _notificationService.showEmergencyNotification(
      title: 'Emergency Alert',
      body: message,
      payload: alertType,
    );
  }
  
  void _handleCircleInvitation(Map<String, dynamic> data) {
    final circleName = data['circle_name'] as String;
    final invitedBy = data['invited_by'] as String;
    
    _notificationService.showCircleNotification(
      title: 'Circle Invitation',
      body: '$invitedBy invited you to $circleName',
      payload: data['circle_id'] as String,
    );
  }
  
  void send(Map<String, dynamic> data) {
    if (_channel != null && state.isConnected) {
      _channel!.sink.add(data);
    }
  }
  
  void disconnect() {
    _channel?.sink.close();
    state = state.copyWith(isConnected: false, isConnecting: false);
  }
  
  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
