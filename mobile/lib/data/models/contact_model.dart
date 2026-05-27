import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/contact.dart';

part 'contact_model.g.dart';

@JsonSerializable()
class ContactModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String name;
  final String phone;
  @JsonKey(name: 'hashed_phone')
  final String? hashedPhone;
  final String? relationship;
  @JsonKey(name: 'is_emergency')
  final bool isEmergency;
  @JsonKey(name: 'can_share_location')
  final bool canShareLocation;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'notification_count')
  final int notificationCount;
  
  ContactModel({
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
  
  factory ContactModel.fromJson(Map<String, dynamic> json) => 
      _$ContactModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ContactModelToJson(this);
  
  Contact toEntity() {
    return Contact(
      id: id,
      userId: userId,
      name: name,
      phone: phone,
      hashedPhone: hashedPhone,
      relationship: relationship,
      isEmergency: isEmergency,
      canShareLocation: canShareLocation,
      createdAt: createdAt,
      updatedAt: updatedAt,
      notificationCount: notificationCount,
    );
  }
  
  factory ContactModel.fromEntity(Contact contact) {
    return ContactModel(
      id: contact.id,
      userId: contact.userId,
      name: contact.name,
      phone: contact.phone,
      hashedPhone: contact.hashedPhone,
      relationship: contact.relationship,
      isEmergency: contact.isEmergency,
      canShareLocation: contact.canShareLocation,
      createdAt: contact.createdAt,
      updatedAt: contact.updatedAt,
      notificationCount: contact.notificationCount,
    );
  }
}
