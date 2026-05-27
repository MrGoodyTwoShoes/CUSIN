class Incident {
  final String id;
  final String userId;
  final String incidentType;
  final String? description;
  final double latitude;
  final double longitude;
  final String? h3Cell;
  final String severity;
  final double confidenceScore;
  final String status;
  final DateTime incidentTime;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final int corroborationCount;
  final List<String>? evidenceUrls;
  final bool isAnonymous;
  final String? anonymousId;
  
  Incident({
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
  
  Incident copyWith({
    String? id,
    String? userId,
    String? incidentType,
    String? description,
    double? latitude,
    double? longitude,
    String? h3Cell,
    String? severity,
    double? confidenceScore,
    String? status,
    DateTime? incidentTime,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    int? corroborationCount,
    List<String>? evidenceUrls,
    bool? isAnonymous,
    String? anonymousId,
  }) {
    return Incident(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      incidentType: incidentType ?? this.incidentType,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      h3Cell: h3Cell ?? this.h3Cell,
      severity: severity ?? this.severity,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
      incidentTime: incidentTime ?? this.incidentTime,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      corroborationCount: corroborationCount ?? this.corroborationCount,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      anonymousId: anonymousId ?? this.anonymousId,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Incident && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
