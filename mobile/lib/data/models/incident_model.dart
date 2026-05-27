import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/incident.dart';

part 'incident_model.g.dart';

@JsonSerializable()
class IncidentModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'incident_type')
  final String incidentType;
  final String? description;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'h3_cell')
  final String? h3Cell;
  final String severity;
  @JsonKey(name: 'confidence_score')
  final double confidenceScore;
  final String status;
  @JsonKey(name: 'incident_time')
  final DateTime incidentTime;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @JsonKey(name: 'approved_by')
  final String? approvedBy;
  @JsonKey(name: 'corroboration_count')
  final int corroborationCount;
  @JsonKey(name: 'evidence_urls')
  final List<String>? evidenceUrls;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
  @JsonKey(name: 'anonymous_id')
  final String? anonymousId;
  
  IncidentModel({
    required this.id,
    required this.userId,
    required this.incidentType,
    this.description,
    required this.latitude,
    required this.longitude,
    this.h3Cell,
    required this.severity,
    required this.confidenceScore,
    required this.status,
    required this.incidentTime,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.corroborationCount = 0,
    this.evidenceUrls,
    this.isAnonymous = false,
    this.anonymousId,
  });
  
  factory IncidentModel.fromJson(Map<String, dynamic> json) => 
      _$IncidentModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$IncidentModelToJson(this);
  
  Incident toEntity() {
    return Incident(
      id: id,
      userId: userId,
      incidentType: incidentType,
      description: description,
      latitude: latitude,
      longitude: longitude,
      h3Cell: h3Cell,
      severity: severity,
      confidenceScore: confidenceScore,
      status: status,
      incidentTime: incidentTime,
      createdAt: createdAt,
      approvedAt: approvedAt,
      approvedBy: approvedBy,
      corroborationCount: corroborationCount,
      evidenceUrls: evidenceUrls,
      isAnonymous: isAnonymous,
      anonymousId: anonymousId,
    );
  }
  
  factory IncidentModel.fromEntity(Incident incident) {
    return IncidentModel(
      id: incident.id,
      userId: incident.userId,
      incidentType: incident.incidentType,
      description: incident.description,
      latitude: incident.latitude,
      longitude: incident.longitude,
      h3Cell: incident.h3Cell,
      severity: incident.severity,
      confidenceScore: incident.confidenceScore,
      status: incident.status,
      incidentTime: incident.incidentTime,
      createdAt: incident.createdAt,
      approvedAt: incident.approvedAt,
      approvedBy: incident.approvedBy,
      corroborationCount: incident.corroborationCount,
      evidenceUrls: incident.evidenceUrls,
      isAnonymous: incident.isAnonymous,
      anonymousId: incident.anonymousId,
    );
  }
}
