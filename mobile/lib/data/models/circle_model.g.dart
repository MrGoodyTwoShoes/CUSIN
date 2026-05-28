// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'circle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CircleModel _$CircleModelFromJson(Map<String, dynamic> json) => CircleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
      isPublic: json['is_public'] as bool? ?? false,
      locationH3Cell: json['location_h3_cell'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 1000,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$CircleModelToJson(CircleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'member_count': instance.memberCount,
      'is_public': instance.isPublic,
      'location_h3_cell': instance.locationH3Cell,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius_meters': instance.radiusMeters,
      'is_active': instance.isActive,
    };
