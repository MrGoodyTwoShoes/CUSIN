import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/datasources/remote/remote_datasource.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/incident_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/verify_phone_usecase.dart';
import '../../domain/usecases/incidents/create_incident_usecase.dart';
import '../../domain/usecases/incidents/get_incidents_usecase.dart';
import 'auth_provider.dart';
import 'circle_provider.dart';
import 'incident_provider.dart';

/// Dio client provider
final dioClientProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.cusin.app',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));
});

/// Network info provider
final networkInfoProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Local datasource provider
final localDataSourceProvider = Provider<LocalDataSourceImpl>((ref) {
  return LocalDataSourceImpl();
});

/// Remote datasource provider
final remoteDataSourceProvider = Provider<RemoteDataSourceImpl>((ref) {
  return RemoteDataSourceImpl(ref.read(dioClientProvider));
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
  );
});

/// Incident repository provider
final incidentRepositoryProvider = Provider<IncidentRepositoryImpl>((ref) {
  return IncidentRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
    localDataSource: ref.read(localDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// Login usecase provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

/// Verify phone usecase provider
final verifyPhoneUseCaseProvider = Provider<VerifyPhoneUseCase>((ref) {
  return VerifyPhoneUseCase(ref.read(authRepositoryProvider));
});

/// Get incidents usecase provider
final getIncidentsUseCaseProvider = Provider<GetIncidentsUseCase>((ref) {
  return GetIncidentsUseCase(ref.read(incidentRepositoryProvider));
});

/// Create incident usecase provider
final createIncidentUseCaseProvider = Provider<CreateIncidentUseCase>((ref) {
  return CreateIncidentUseCase(ref.read(incidentRepositoryProvider));
});

/// Auth provider
final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  return AuthProvider(
    loginUseCase: ref.read(loginUseCaseProvider),
    verifyPhoneUseCase: ref.read(verifyPhoneUseCaseProvider),
  );
});

/// Incident provider
final incidentProvider = StateNotifierProvider<IncidentProvider, IncidentState>((ref) {
  return IncidentProvider(
    getIncidentsUseCase: ref.read(getIncidentsUseCaseProvider),
    createIncidentUseCase: ref.read(createIncidentUseCaseProvider),
  );
});

/// Circle provider
final circleProvider = StateNotifierProvider<CircleProvider, CircleState>((ref) {
  return CircleProvider();
});

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

/// Accessibility settings provider
final accessibilitySettingsProvider = StateNotifierProvider<AccessibilitySettingsNotifier, AccessibilitySettings>((ref) {
  return AccessibilitySettingsNotifier();
});

/// Accessibility settings
class AccessibilitySettings {
  final bool screenReaderEnabled;
  final bool highContrastMode;
  final bool largeTextEnabled;
  final bool reduceMotion;
  final double textScaleFactor;

  AccessibilitySettings({
    this.screenReaderEnabled = false,
    this.highContrastMode = false,
    this.largeTextEnabled = false,
    this.reduceMotion = false,
    this.textScaleFactor = 1.0,
  });

  AccessibilitySettings copyWith({
    bool? screenReaderEnabled,
    bool? highContrastMode,
    bool? largeTextEnabled,
    bool? reduceMotion,
    double? textScaleFactor,
  }) {
    return AccessibilitySettings(
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      largeTextEnabled: largeTextEnabled ?? this.largeTextEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}

/// Accessibility settings notifier
class AccessibilitySettingsNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilitySettingsNotifier() : super(AccessibilitySettings());

  void toggleScreenReader(bool value) {
    state = state.copyWith(screenReaderEnabled: value);
  }

  void toggleHighContrast(bool value) {
    state = state.copyWith(highContrastMode: value);
  }

  void toggleLargeText(bool value) {
    state = state.copyWith(
      largeTextEnabled: value,
      textScaleFactor: value ? 1.3 : 1.0,
    );
  }

  void toggleReduceMotion(bool value) {
    state = state.copyWith(reduceMotion: value);
  }
}

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Notification service
class NotificationService {
  Future<void> initialize() async {
    // Initialize local notifications
    // Implementation would use flutter_local_notifications
  }
}

/// WebSocket service provider
final websocketServiceProvider = StateNotifierProvider<WebSocketServiceNotifier, WebSocketState>((ref) {
  return WebSocketServiceNotifier();
});

/// WebSocket state
class WebSocketState {
  final bool isConnected;
  final String? error;

  WebSocketState({this.isConnected = false, this.error});
}

/// WebSocket service notifier
class WebSocketServiceNotifier extends StateNotifier<WebSocketState> {
  WebSocketServiceNotifier() : super(WebSocketState());

  Future<void> initialize() async {
    // Initialize WebSocket connection
    // Implementation would use web_socket_channel
    try {
      // Connect to WebSocket server
      state = WebSocketState(isConnected: true);
    } catch (e) {
      state = WebSocketState(isConnected: false, error: e.toString());
    }
  }

  void disconnect() {
    // Disconnect WebSocket
    state = WebSocketState(isConnected: false);
  }
}
