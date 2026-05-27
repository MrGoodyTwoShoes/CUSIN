import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/repositories/incident_repository.dart';
import '../usecase.dart';

/// Create incident usecase
class CreateIncidentUseCase implements UseCase<Incident, CreateIncidentParams> {
  final IncidentRepository repository;
  
  CreateIncidentUseCase(this.repository);
  
  @override
  Future<Either<Failure, Incident>> call(CreateIncidentParams params) async {
    return await repository.createIncident(
      incidentType: params.incidentType,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
      severity: params.severity,
      isAnonymous: params.isAnonymous,
      evidenceUrls: params.evidenceUrls,
    );
  }
}

class CreateIncidentParams {
  final String incidentType;
  final String? description;
  final double latitude;
  final double longitude;
  final String severity;
  final bool isAnonymous;
  final List<String>? evidenceUrls;
  
  CreateIncidentParams({
    required this.incidentType,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.severity,
    this.isAnonymous = false,
    this.evidenceUrls,
  });
}
