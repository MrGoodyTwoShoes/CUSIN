import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String phone;
  @JsonKey(name: 'hashed_phone')
  final String? hashedPhone;
  @JsonKey(name: 'trust_score')
  final double trustScore;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_active_at')
  final DateTime? lastActiveAt;
  @JsonKey(name: 'is_anonymous')
  final bool isAnonymous;
  @JsonKey(name: 'device_info')
  final String? deviceInfo;
  
  UserModel({
    required this.id,
    required this.phone,
    this.hashedPhone,
    required this.trustScore,
    required this.createdAt,
    this.lastActiveAt,
    this.isAnonymous = false,
    this.deviceInfo,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => 
      _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  User toEntity() {
    return User(
      id: id,
      phone: phone,
      hashedPhone: hashedPhone,
      trustScore: trustScore,
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
      isAnonymous: isAnonymous,
      deviceInfo: deviceInfo,
    );
  }
  
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phone: user.phone,
      hashedPhone: user.hashedPhone,
      trustScore: user.trustScore,
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
      isAnonymous: user.isAnonymous,
      deviceInfo: user.deviceInfo,
    );
  }
}
