import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/incident.dart';

/// Incident repository interface
abstract class IncidentRepository {
  Future<Either<Failure, Incident>> createIncident({
    required String incidentType,
    String? description,
    required double latitude,
    required double longitude,
    required String severity,
    bool isAnonymous = false,
    List<String>? evidenceUrls,
  });
  
  Future<Either<Failure, List<Incident>>> getNearbyIncidents({
    required double lat,
    required double lng,
    double radius = 2,
    int limit = 50,
  });
  
  Future<Either<Failure, List<dynamic>>> getHeatmap({String layer = 'recent'});
  Future<Either<Failure, Incident>> getIncidentById(String id);
  Future<Either<Failure, Incident>> corroborateIncident(String id);
  Future<Either<Failure, String>> uploadEvidence(String filePath);
  Future<Either<Failure, void>> syncOfflineQueue();
}
