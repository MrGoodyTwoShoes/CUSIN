import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/circle.dart';

part 'circle_model.g.dart';

@JsonSerializable()
class CircleModel {
  final String id;
  final String name;
  final String description;
  @JsonKey(name: 'created_by')
  final String createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'member_count')
  final int memberCount;
  @JsonKey(name: 'is_public')
  final bool isPublic;
  @JsonKey(name: 'location_h3_cell')
  final String? locationH3Cell;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'radius_meters')
  final double radiusMeters;
  @JsonKey(name: 'is_active')
  final bool isActive;
  
  CircleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.memberCount = 0,
    this.isPublic = false,
    this.locationH3Cell,
    this.latitude,
    this.longitude,
    this.radiusMeters = 1000,
    this.isActive = true,
  });
  
  factory CircleModel.fromJson(Map<String, dynamic> json) => 
      _$CircleModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$CircleModelToJson(this);
  
  Circle toEntity() {
    return Circle(
      id: id,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      memberCount: memberCount,
      isPublic: isPublic,
      locationH3Cell: locationH3Cell,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      isActive: isActive,
    );
  }
  
  factory CircleModel.fromEntity(Circle circle) {
    return CircleModel(
      id: circle.id,
      name: circle.name,
      description: circle.description,
      createdBy: circle.createdBy,
      createdAt: circle.createdAt,
      updatedAt: circle.updatedAt,
      memberCount: circle.memberCount,
      isPublic: circle.isPublic,
      locationH3Cell: circle.locationH3Cell,
      latitude: circle.latitude,
      longitude: circle.longitude,
      radiusMeters: circle.radiusMeters,
      isActive: circle.isActive,
    );
  }
}
