// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      phone: json['phone'] as String,
      hashedPhone: json['hashed_phone'] as String?,
      trustScore: (json['trust_score'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActiveAt: json['last_active_at'] == null
          ? null
          : DateTime.parse(json['last_active_at'] as String),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      deviceInfo: json['device_info'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'hashed_phone': instance.hashedPhone,
      'trust_score': instance.trustScore,
      'created_at': instance.createdAt.toIso8601String(),
      'last_active_at': instance.lastActiveAt?.toIso8601String(),
      'is_anonymous': instance.isAnonymous,
      'device_info': instance.deviceInfo,
    };
