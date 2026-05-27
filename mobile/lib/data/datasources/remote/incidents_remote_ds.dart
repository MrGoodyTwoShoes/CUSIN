import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/incident_model.dart';
import 'remote_datasource.dart';

/// Incidents remote datasource
class IncidentsRemoteDataSource {
  final RemoteDataSource remoteDataSource;
  
  IncidentsRemoteDataSource(this.remoteDataSource);
  
  /// Create incident
  Future<IncidentModel> createIncident({
    required String incidentType,
    String? description,
    required double latitude,
    required double longitude,
    required String severity,
    bool isAnonymous = false,
    List<String>? evidenceUrls,
  }) async {
    try {
      final response = await remoteDataSource.post(
        ApiConstants.incidents,
        data: {
          'incident_type': incidentType,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'severity': severity,
          'is_anonymous': isAnonymous,
          'evidence_urls': evidenceUrls,
        },
      );
      
      if (response.statusCode == 201) {
        return IncidentModel.fromJson(response.data['data']['incident']);
      } else {
        throw ServerException('Failed to create incident');
      }
    } catch (e) {
      throw ServerException('Create incident error: $e');
    }
  }
  
  /// Get nearby incidents
  Future<List<IncidentModel>> getNearbyIncidents({
    required double lat,
    required double lng,
    double radius = 2,
    int limit = 50,
  }) async {
    try {
      final response = await remoteDataSource.get(
        ApiConstants.incidents,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
          'limit': limit,
        },
      );
      
      if (response.statusCode == 200) {
        final incidents = response.data['data']['incidents'] as List;
        return incidents.map((json) => IncidentModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get incidents');
      }
    } catch (e) {
      throw ServerException('Get incidents error: $e');
    }
  }
  
  /// Get heatmap data
  Future<List<dynamic>> getHeatmap({String layer = 'recent'}) async {
    try {
      final response = await remoteDataSource.get(
        ApiConstants.incidentHeatmap,
        queryParameters: {'layer': layer},
      );
      
      if (response.statusCode == 200) {
        return response.data['data']['heatmap'] as List;
      } else {
        throw ServerException('Failed to get heatmap');
      }
    } catch (e) {
      throw ServerException('Get heatmap error: $e');
    }
  }
  
  /// Get incident by ID
  Future<IncidentModel> getIncidentById(String id) async {
    try {
      final response = await remoteDataSource.get('${ApiConstants.incidents}/$id');
      
      if (response.statusCode == 200) {
        return IncidentModel.fromJson(response.data['data']['incident']);
      } else {
        throw NotFoundException('Incident not found');
      }
    } catch (e) {
      throw NotFoundException('Get incident error: $e');
    }
  }
  
  /// Corroborate incident
  Future<IncidentModel> corroborateIncident(String id) async {
    try {
      final response = await remoteDataSource.post(
        '${ApiConstants.incidents}/$id/corroborate',
      );
      
      if (response.statusCode == 200) {
        return IncidentModel.fromJson(response.data['data']['incident']);
      } else {
        throw ServerException('Failed to corroborate incident');
      }
    } catch (e) {
      throw ServerException('Corroborate incident error: $e');
    }
  }
  
  /// Upload evidence
  Future<String> uploadEvidence(String filePath) async {
    try {
      final response = await remoteDataSource.uploadFile(
        '${ApiConstants.incidents}/evidence',
        filePath,
      );
      
      if (response.statusCode == 200) {
        return response.data['data']['url'];
      } else {
        throw ServerException('Failed to upload evidence');
      }
    } catch (e) {
      throw ServerException('Upload evidence error: $e');
    }
  }
}
