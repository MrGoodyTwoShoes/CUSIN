import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/repositories/incident_repository.dart';
import '../usecase.dart';

/// Get incidents usecase
class GetIncidentsUseCase implements UseCase<List<Incident>, GetIncidentsParams> {
  final IncidentRepository repository;
  
  GetIncidentsUseCase(this.repository);
  
  @override
  Future<Either<Failure, List<Incident>>> call(GetIncidentsParams params) async {
    return await repository.getNearbyIncidents(
      lat: params.lat,
      lng: params.lng,
      radius: params.radius,
      limit: params.limit,
    );
  }
}

class GetIncidentsParams {
  final double lat;
  final double lng;
  final double radius;
  final int limit;
  
  GetIncidentsParams({
    required this.lat,
    required this.lng,
    this.radius = 2,
    this.limit = 50,
  });
}
