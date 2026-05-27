class Contact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String? hashedPhone;
  final String? relationship;
  final bool isEmergency;
  final bool canShareLocation;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int notificationCount;
  
  Contact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.hashedPhone,
    this.relationship,
    this.isEmergency = false,
    this.canShareLocation = true,
    required this.createdAt,
    this.updatedAt,
    this.notificationCount = 0,
  });
  
  Contact copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? hashedPhone,
    String? relationship,
    bool? isEmergency,
    bool? canShareLocation,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? notificationCount,
  }) {
    return Contact(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      hashedPhone: hashedPhone ?? this.hashedPhone,
      relationship: relationship ?? this.relationship,
      isEmergency: isEmergency ?? this.isEmergency,
      canShareLocation: canShareLocation ?? this.canShareLocation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
