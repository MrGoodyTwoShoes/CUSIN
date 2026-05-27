import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/circle.dart';

/// Circle repository interface
abstract class CircleRepository {
  Future<Either<Failure, List<Circle>>> getUserCircles();
  Future<Either<Failure, Circle>> createCircle({
    required String name,
    required String description,
    bool isPublic = false,
    double? latitude,
    double? longitude,
    double radiusMeters = 1000,
  });
  Future<Either<Failure, Circle>> getCircleById(String id);
  Future<Either<Failure, void>> joinCircle(String circleId);
  Future<Either<Failure, void>> leaveCircle(String circleId);
  Future<Either<Failure, List<dynamic>>> getCircleMembers(String circleId);
}
