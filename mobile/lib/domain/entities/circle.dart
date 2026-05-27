class Circle {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int memberCount;
  final bool isPublic;
  final String? locationH3Cell;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;
  final bool isActive;
  
  Circle({
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
  
  Circle copyWith({
    String? id,
    String? name,
    String? description,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? memberCount,
    bool? isPublic,
    String? locationH3Cell,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? isActive,
  }) {
    return Circle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      isPublic: isPublic ?? this.isPublic,
      locationH3Cell: locationH3Cell ?? this.locationH3Cell,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isActive: isActive ?? this.isActive,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Circle && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
