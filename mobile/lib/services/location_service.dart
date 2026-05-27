import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_constants.dart';
import '../core/error/exceptions.dart';

/// Location state
class LocationState {
  final Position? currentPosition;
  final bool hasPermission;
  final bool isLoading;
  final String? error;
  
  LocationState({
    this.currentPosition,
    this.hasPermission = false,
    this.isLoading = false,
    this.error,
  });
  
  LocationState copyWith({
    Position? currentPosition,
    bool? hasPermission,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Location service provider
final locationServiceProvider = StateNotifierProvider<LocationServiceNotifier, LocationState>(
  (ref) => LocationServiceNotifier(),
);

/// Location service notifier with Riverpod
class LocationServiceNotifier extends StateNotifier<LocationState> {
  Stream<Position>? _positionStream;
  
  LocationServiceNotifier() : super(LocationState());
  
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled. Please enable them in settings.',
        );
        return;
      }
      
      // Check permission
      final permission = await Geolocator.checkPermission();
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      
      state = state.copyWith(
        hasPermission: hasPermission,
        isLoading: false,
      );
      
      if (hasPermission) {
        await getCurrentLocation();
        _startLocationStream();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<bool> requestPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      final hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      
      state = state.copyWith(hasPermission: hasPermission);
      
      if (hasPermission) {
        await getCurrentLocation();
        _startLocationStream();
      }
      
      return hasPermission;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
  
  Future<Position> getCurrentLocation() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      state = state.copyWith(
        currentPosition: position,
        isLoading: false,
        error: null,
      );
      
      return position;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      throw LocationException('Failed to get current location: $e');
    }
  }
  
  void _startLocationStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.defaultLocationAccuracy,
    );
    
    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    
    _positionStream?.listen(
      (position) {
        state = state.copyWith(currentPosition: position);
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }
  
  /// Fuzz location for privacy
  Position fuzzLocation(Position position) {
    final random = position.timestamp.millisecondsSinceEpoch;
    final fuzzRadius = AppConstants.locationFuzzRadius;
    
    // Add random offset within fuzz radius
    final latOffset = (random % (fuzzRadius * 2)) - fuzzRadius;
    final lngOffset = (random % (fuzzRadius * 2)) - fuzzRadius;
    
    // Convert meters to degrees (approximate)
    final latOffsetDeg = latOffset / 111111;
    final lngOffsetDeg = lngOffset / (111111 * position.latitude.cos());
    
    return Position(
      latitude: position.latitude + latOffsetDeg,
      longitude: position.longitude + lngOffsetDeg,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      altitude: position.altitude,
      altitudeAccuracy: position.altitudeAccuracy,
      heading: position.heading,
      headingAccuracy: position.headingAccuracy,
      speed: position.speed,
      speedAccuracy: position.speedAccuracy,
    );
  }
  
  @override
  void dispose() {
    _positionStream?.drain();
    super.dispose();
  }
}
