// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IncidentModel _$IncidentModelFromJson(Map<String, dynamic> json) =>
    IncidentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      incidentType: json['incident_type'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      h3Cell: json['h3_cell'] as String?,
      severity: json['severity'] as String,
      confidenceScore: (json['confidence_score'] as num).toDouble(),
      status: json['status'] as String,
      incidentTime: DateTime.parse(json['incident_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      approvedBy: json['approved_by'] as String?,
      corroborationCount: (json['corroboration_count'] as num?)?.toInt() ?? 0,
      evidenceUrls: (json['evidence_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      anonymousId: json['anonymous_id'] as String?,
    );

Map<String, dynamic> _$IncidentModelToJson(IncidentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'incident_type': instance.incidentType,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'h3_cell': instance.h3Cell,
      'severity': instance.severity,
      'confidence_score': instance.confidenceScore,
      'status': instance.status,
      'incident_time': instance.incidentTime.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'approved_at': instance.approvedAt?.toIso8601String(),
      'approved_by': instance.approvedBy,
      'corroboration_count': instance.corroborationCount,
      'evidence_urls': instance.evidenceUrls,
      'is_anonymous': instance.isAnonymous,
      'anonymous_id': instance.anonymousId,
    };
