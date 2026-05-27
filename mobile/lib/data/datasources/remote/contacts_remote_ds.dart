import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../models/contact_model.dart';
import 'remote_datasource.dart';

/// Contacts remote datasource
class ContactsRemoteDataSource {
  final RemoteDataSource remoteDataSource;
  
  ContactsRemoteDataSource(this.remoteDataSource);
  
  /// Get user's contacts
  Future<List<ContactModel>> getUserContacts() async {
    try {
      final response = await remoteDataSource.get(ApiConstants.contacts);
      
      if (response.statusCode == 200) {
        final contacts = response.data['data']['contacts'] as List;
        return contacts.map((json) => ContactModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to get contacts');
      }
    } catch (e) {
      throw ServerException('Get contacts error: $e');
    }
  }
  
  /// Add contact
  Future<ContactModel> addContact({
    required String name,
    required String phone,
    String? relationship,
    bool isEmergency = false,
    bool canShareLocation = true,
  }) async {
    try {
      final response = await remoteDataSource.post(
        ApiConstants.contacts,
        data: {
          'name': name,
          'phone': phone,
          'relationship': relationship,
          'is_emergency': isEmergency,
          'can_share_location': canShareLocation,
        },
      );
      
      if (response.statusCode == 201) {
        return ContactModel.fromJson(response.data['data']['contact']);
      } else {
        throw ServerException('Failed to add contact');
      }
    } catch (e) {
      throw ServerException('Add contact error: $e');
    }
  }
  
  /// Update contact
  Future<ContactModel> updateContact({
    required String id,
    String? name,
    String? phone,
    String? relationship,
    bool? isEmergency,
    bool? canShareLocation,
  }) async {
    try {
      final response = await remoteDataSource.put(
        '${ApiConstants.contacts}/$id',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (relationship != null) 'relationship': relationship,
          if (isEmergency != null) 'is_emergency': isEmergency,
          if (canShareLocation != null) 'can_share_location': canShareLocation,
        },
      );
      
      if (response.statusCode == 200) {
        return ContactModel.fromJson(response.data['data']['contact']);
      } else {
        throw ServerException('Failed to update contact');
      }
    } catch (e) {
      throw ServerException('Update contact error: $e');
    }
  }
  
  /// Delete contact
  Future<void> deleteContact(String id) async {
    try {
      final response = await remoteDataSource.delete('${ApiConstants.contacts}/$id');
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to delete contact');
      }
    } catch (e) {
      throw ServerException('Delete contact error: $e');
    }
  }
  
  /// Notify contacts
  Future<void> notifyContacts({
    required List<String> contactIds,
    required String message,
    String? location,
  }) async {
    try {
      final response = await remoteDataSource.post(
        '${ApiConstants.contacts}/notify',
        data: {
          'contact_ids': contactIds,
          'message': message,
          'location': location,
        },
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to notify contacts');
      }
    } catch (e) {
      throw ServerException('Notify contacts error: $e');
    }
  }
}
