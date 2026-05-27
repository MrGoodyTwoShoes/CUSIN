class Incident {
  final String id;
  final String incidentType;
  final String? description;
  final double latitude;
  final double longitude;
  final String severity;
  final double confidenceScore;
  final String status;
  final DateTime incidentTime;
  final DateTime createdAt;
  final String? h3Cell;
  
  Incident({
    required this.id,
    required this.incidentType,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.severity,
    required this.confidenceScore,
    required this.status,
    required this.incidentTime,
    required this.createdAt,
    this.h3Cell,
  });
  
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      incidentType: json['incident_type'],
      description: json['description'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      severity: json['severity'],
      confidenceScore: double.parse(json['confidence_score'].toString()),
      status: json['status'],
      incidentTime: DateTime.parse(json['incident_time']),
      createdAt: DateTime.parse(json['created_at']),
      h3Cell: json['h3_cell'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_type': incidentType,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'severity': severity,
      'confidence_score': confidenceScore,
      'status': status,
      'incident_time': incidentTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'h3_cell': h3Cell,
    };
  }
}
