// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactModel _$ContactModelFromJson(Map<String, dynamic> json) => ContactModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      hashedPhone: json['hashed_phone'] as String?,
      relationship: json['relationship'] as String?,
      isEmergency: json['is_emergency'] as bool? ?? false,
      canShareLocation: json['can_share_location'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      notificationCount: (json['notification_count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ContactModelToJson(ContactModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'phone': instance.phone,
      'hashed_phone': instance.hashedPhone,
      'relationship': instance.relationship,
      'is_emergency': instance.isEmergency,
      'can_share_location': instance.canShareLocation,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'notification_count': instance.notificationCount,
    };
