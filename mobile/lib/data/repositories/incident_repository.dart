import 'package:dartz/dartz.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../core/network/network_info.dart';
import '../../../domain/entities/incident.dart';
import '../../../domain/repositories/incident_repository.dart';
import '../datasources/incidents_local_ds.dart';
import '../datasources/remote/incidents_remote_ds.dart';
import '../models/incident_model.dart';

/// Incident repository implementation
class IncidentRepositoryImpl implements IncidentRepository {
  final IncidentsRemoteDataSource remoteDataSource;
  final IncidentsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  IncidentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, Incident>> createIncident({
    required String incidentType,
    String? description,
    required double latitude,
    required double longitude,
    required String severity,
    bool isAnonymous = false,
    List<String>? evidenceUrls,
  }) async {
    final isConnected = await networkInfo.isConnected;
    
    if (!isConnected) {
      // Add to offline queue
      try {
        final incident = IncidentModel(
          id: '', // Will be assigned by server
          userId: '', // Will be assigned by server
          incidentType: incidentType,
          description: description,
          latitude: latitude,
          longitude: longitude,
          severity: severity,
          confidenceScore: 0.5,
          status: 'pending',
          incidentTime: DateTime.now(),
          createdAt: DateTime.now(),
          isAnonymous: isAnonymous,
          evidenceUrls: evidenceUrls,
        );
        
        await localDataSource.addIncidentToQueue(incident);
        return Left(NetworkFailure('No internet connection. Incident queued for sync.'));
      } catch (e) {
        return Left(StorageFailure('Failed to queue incident: $e'));
      }
    }
    
    try {
      final incidentModel = await remoteDataSource.createIncident(
        incidentType: incidentType,
        description: description,
        latitude: latitude,
        longitude: longitude,
        severity: severity,
        isAnonymous: isAnonymous,
        evidenceUrls: evidenceUrls,
      );
      
      // Update cache
      final cachedIncidents = await localDataSource.getCachedIncidents();
      cachedIncidents.add(incidentModel);
      await localDataSource.cacheIncidents(cachedIncidents);
      
      return Right(incidentModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Incident>>> getNearbyIncidents({
    required double lat,
    required double lng,
    double radius = 2,
    int limit = 50,
  }) async {
    final isConnected = await networkInfo.isConnected;
    
    if (isConnected) {
      try {
        final incidents = await remoteDataSource.getNearbyIncidents(
          lat: lat,
          lng: lng,
          radius: radius,
          limit: limit,
        );
        
        // Cache the results
        await localDataSource.cacheIncidents(incidents);
        
        return Right(incidents.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      // Return cached data if available
      try {
        final isCacheValid = await localDataSource.isCacheValid();
        if (isCacheValid) {
          final cachedIncidents = await localDataSource.getCachedIncidents();
          return Right(cachedIncidents.map((model) => model.toEntity()).toList());
        } else {
          return Left(NetworkFailure('No internet connection and cache expired'));
        }
      } catch (e) {
        return Left(CacheFailure('Failed to get cached incidents: $e'));
      }
    }
  }
  
  @override
  Future<Either<Failure, List<dynamic>>> getHeatmap({String layer = 'recent'}) async {
    try {
      final heatmap = await remoteDataSource.getHeatmap(layer: layer);
      return Right(heatmap);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Incident>> getIncidentById(String id) async {
    try {
      final incident = await remoteDataSource.getIncidentById(id);
      return Right(incident.toEntity());
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Incident>> corroborateIncident(String id) async {
    try {
      final incident = await remoteDataSource.corroborateIncident(id);
      return Right(incident.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, String>> uploadEvidence(String filePath) async {
    try {
      final url = await remoteDataSource.uploadEvidence(filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> syncOfflineQueue() async {
    try {
      final queue = await localDataSource.getIncidentQueue();
      
      for (int i = 0; i < queue.length; i++) {
        try {
          final incidentData = queue[i];
          final incident = IncidentModel.fromJson(incidentData);
          
          await remoteDataSource.createIncident(
            incidentType: incident.incidentType,
            description: incident.description,
            latitude: incident.latitude,
            longitude: incident.longitude,
            severity: incident.severity,
            isAnonymous: incident.isAnonymous,
            evidenceUrls: incident.evidenceUrls,
          );
          
          // Remove from queue on success
          await localDataSource.removeIncidentFromQueue(i);
          i--; // Adjust index after removal
        } catch (e) {
          // Continue with next item on failure
          continue;
        }
      }
      
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
