class User {
  final String id;
  final String phone;
  final String? hashedPhone;
  final double trustScore;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final bool isAnonymous;
  final String? deviceInfo;
  
  User({
    required this.id,
    required this.phone,
    this.hashedPhone,
    required this.trustScore,
    required this.createdAt,
    this.lastActiveAt,
    this.isAnonymous = false,
    this.deviceInfo,
  });
  
  User copyWith({
    String? id,
    String? phone,
    String? hashedPhone,
    double? trustScore,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    bool? isAnonymous,
    String? deviceInfo,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      hashedPhone: hashedPhone ?? this.hashedPhone,
      trustScore: trustScore ?? this.trustScore,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
