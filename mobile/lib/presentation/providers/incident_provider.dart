import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/incident.dart';
import '../../domain/usecases/incidents/create_incident_usecase.dart';
import '../../domain/usecases/incidents/get_incidents_usecase.dart';

/// Incident state
class IncidentState {
  final List<Incident> incidents;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  
  IncidentState({
    this.incidents = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
  });
  
  IncidentState copyWith({
    List<Incident>? incidents,
    bool? isLoading,
    String? error,
    bool? isCreating,
  }) {
    return IncidentState(
      incidents: incidents ?? this.incidents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

/// Incident provider
class IncidentProvider extends StateNotifier<IncidentState> {
  final GetIncidentsUseCase getIncidentsUseCase;
  final CreateIncidentUseCase createIncidentUseCase;
  
  IncidentProvider({
    required this.getIncidentsUseCase,
    required this.createIncidentUseCase,
  }) : super(IncidentState());
  
  /// Get nearby incidents
  Future<void> getNearbyIncidents({
    required double lat,
    required double lng,
    double radius = 2,
    int limit = 50,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await getIncidentsUseCase(
      GetIncidentsParams(
        lat: lat,
        lng: lng,
        radius: radius,
        limit: limit,
      ),
    );
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (incidents) {
        state = state.copyWith(
          incidents: incidents,
          isLoading: false,
        );
      },
    );
  }
  
  /// Create incident
  Future<void> createIncident({
    required String incidentType,
    String? description,
    required double latitude,
    required double longitude,
    required String severity,
    bool isAnonymous = false,
    List<String>? evidenceUrls,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    
    final result = await createIncidentUseCase(
      CreateIncidentParams(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        severity: severity,
        isAnonymous: isAnonymous,
        evidenceUrls: evidenceUrls,
      ),
    );
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isCreating: false,
          error: _mapFailureToMessage(failure),
        );
      },
      (incident) {
        state = state.copyWith(
          incidents: [incident, ...state.incidents],
          isCreating: false,
        );
      },
    );
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Incident queued for sync.';
      case ValidationFailure:
        return failure.message;
      default:
        return 'An unexpected error occurred.';
    }
  }
}
