import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/circle_model.dart';
import 'remote_datasource.dart';

/// Circles remote datasource
class CirclesRemoteDataSource {
  final RemoteDataSource remoteDataSource;
  
  CirclesRemoteDataSource(this.remoteDataSource);
  
  /// Get user's circles
  Future<List<CircleModel>> getUserCircles() async {
    try {
      final response = await remoteDataSource.get(ApiConstants.circles);
      
      if (response.statusCode == 200) {
        final circles = response.data['data']['circles'] as List;
        return circles.map((json) => CircleModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get circles');
      }
    } catch (e) {
      throw ServerException('Get circles error: $e');
    }
  }
  
  /// Create circle
  Future<CircleModel> createCircle({
    required String name,
    required String description,
    bool isPublic = false,
    double? latitude,
    double? longitude,
    double radiusMeters = 1000,
  }) async {
    try {
      final response = await remoteDataSource.post(
        ApiConstants.circles,
        data: {
          'name': name,
          'description': description,
          'is_public': isPublic,
          'latitude': latitude,
          'longitude': longitude,
          'radius_meters': radiusMeters,
        },
      );
      
      if (response.statusCode == 201) {
        return CircleModel.fromJson(response.data['data']['circle']);
      } else {
        throw ServerException('Failed to create circle');
      }
    } catch (e) {
      throw ServerException('Create circle error: $e');
    }
  }
  
  /// Get circle by ID
  Future<CircleModel> getCircleById(String id) async {
    try {
      final response = await remoteDataSource.get('${ApiConstants.circles}/$id');
      
      if (response.statusCode == 200) {
        return CircleModel.fromJson(response.data['data']['circle']);
      } else {
        throw NotFoundException('Circle not found');
      }
    } catch (e) {
      throw NotFoundException('Get circle error: $e');
    }
  }
  
  /// Join circle
  Future<void> joinCircle(String circleId) async {
    try {
      final response = await remoteDataSource.post(
        '${ApiConstants.circles}/$circleId/join',
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to join circle');
      }
    } catch (e) {
      throw ServerException('Join circle error: $e');
    }
  }
  
  /// Leave circle
  Future<void> leaveCircle(String circleId) async {
    try {
      final response = await remoteDataSource.post(
        '${ApiConstants.circles}/$circleId/leave',
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to leave circle');
      }
    } catch (e) {
      throw ServerException('Leave circle error: $e');
    }
  }
  
  /// Get circle members
  Future<List<dynamic>> getCircleMembers(String circleId) async {
    try {
      final response = await remoteDataSource.get(
        '${ApiConstants.circles}/$circleId/members',
      );
      
      if (response.statusCode == 200) {
        return response.data['data']['members'] as List;
      } else {
        throw ServerException('Failed to get circle members');
      }
    } catch (e) {
      throw ServerException('Get circle members error: $e');
    }
  }
}
