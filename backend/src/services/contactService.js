const pool = require('../config/database');
const logger = require('../config/logger');

class ContactService {
  async addContact(userId, contactData) {
    try {
      const { contact_name, contact_phone, contact_type, priority } = contactData;

      // Validate phone number
      if (!contact_phone || !/^\+?[1-9]\d{1,14}$/.test(contact_phone)) {
        throw new Error('Invalid phone number');
      }

      const query = `
        INSERT INTO trusted_contacts (user_id, contact_name, contact_phone, contact_type, priority)
        VALUES ($1, $2, $3, $4, $5)
        RETURNING id, contact_name, contact_phone, contact_type, priority, created_at
      `;

      const result = await pool.query(query, [
        userId,
        contact_name,
        contact_phone,
        contact_type || 'emergency',
        priority || 1
      ]);

      return result.rows[0];
    } catch (error) {
      logger.error('Error adding contact:', error);
      throw error;
    }
  }

  async getContacts(userId, filters = {}) {
    try {
      const { contact_type } = filters;
      
      let query = `
        SELECT id, contact_name, contact_phone, contact_type, priority, created_at
        FROM trusted_contacts
        WHERE user_id = $1
      `;
      const params = [userId];

      if (contact_type) {
        query += ` AND contact_type = $${params.length + 1}`;
        params.push(contact_type);
      }

      query += ' ORDER BY priority ASC, created_at DESC';

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting contacts:', error);
      throw error;
    }
  }

  async getContactById(contactId, userId) {
    try {
      const query = `
        SELECT id, contact_name, contact_phone, contact_type, priority, created_at
        FROM trusted_contacts
        WHERE id = $1 AND user_id = $2
      `;
      const result = await pool.query(query, [contactId, userId]);
      
      if (result.rows.length === 0) {
        return null;
      }

      return result.rows[0];
    } catch (error) {
      logger.error('Error getting contact:', error);
      throw error;
    }
  }

  async updateContact(contactId, userId, updateData) {
    try {
      const { contact_name, contact_phone, contact_type, priority } = updateData;

      // Validate phone number if provided
      if (contact_phone && !/^\+?[1-9]\d{1,14}$/.test(contact_phone)) {
        throw new Error('Invalid phone number');
      }

      const updates = [];
      const params = [];
      let paramIndex = 1;

      if (contact_name !== undefined) {
        updates.push(`contact_name = $${paramIndex++}`);
        params.push(contact_name);
      }
      if (contact_phone !== undefined) {
        updates.push(`contact_phone = $${paramIndex++}`);
        params.push(contact_phone);
      }
      if (contact_type !== undefined) {
        updates.push(`contact_type = $${paramIndex++}`);
        params.push(contact_type);
      }
      if (priority !== undefined) {
        updates.push(`priority = $${paramIndex++}`);
        params.push(priority);
      }

      if (updates.length === 0) {
        throw new Error('No fields to update');
      }

      params.push(contactId, userId);

      const query = `
        UPDATE trusted_contacts
        SET ${updates.join(', ')}
        WHERE id = $${paramIndex++} AND user_id = $${paramIndex}
        RETURNING id, contact_name, contact_phone, contact_type, priority, created_at
      `;

      const result = await pool.query(query, params);
      
      if (result.rows.length === 0) {
        throw new Error('Contact not found');
      }

      return result.rows[0];
    } catch (error) {
      logger.error('Error updating contact:', error);
      throw error;
    }
  }

  async deleteContact(contactId, userId) {
    try {
      const query = `
        DELETE FROM trusted_contacts
        WHERE id = $1 AND user_id = $2
        RETURNING id
      `;
      
      const result = await pool.query(query, [contactId, userId]);

      if (result.rows.length === 0) {
        throw new Error('Contact not found');
      }

      return { success: true };
    } catch (error) {
      logger.error('Error deleting contact:', error);
      throw error;
    }
  }

  async getEmergencyContacts(userId) {
    try {
      const query = `
        SELECT id, contact_name, contact_phone, contact_type, priority, created_at
        FROM trusted_contacts
        WHERE user_id = $1 AND contact_type = 'emergency'
        ORDER BY priority ASC, created_at DESC
      `;
      const result = await pool.query(query, [userId]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting emergency contacts:', error);
      throw error;
    }
  }

  async shareLocationWithContacts(userId, locationData, contactIds = null) {
    try {
      // Get contacts to notify
      let contacts;
      if (contactIds && contactIds.length > 0) {
        const query = `
          SELECT id, contact_name, contact_phone
          FROM trusted_contacts
          WHERE user_id = $1 AND id = ANY($2)
        `;
        const result = await pool.query(query, [userId, contactIds]);
        contacts = result.rows;
      } else {
        contacts = await this.getEmergencyContacts(userId);
      }

      // This would integrate with notification service to send SMS/app notifications
      // For now, return the list of contacts that would be notified
      return {
        userId,
        locationData,
        contacts,
        contactCount: contacts.length
      };
    } catch (error) {
      logger.error('Error sharing location with contacts:', error);
      throw error;
    }
  }

  async escalateEmergency(userId, incidentId, message) {
    try {
      const contacts = await this.getEmergencyContacts(userId);

      // This would integrate with notification service for emergency escalation
      // For now, return the escalation plan
      return {
        userId,
        incidentId,
        message,
        contacts,
        contactCount: contacts.length,
        escalatedAt: new Date().toISOString()
      };
    } catch (error) {
      logger.error('Error escalating emergency:', error);
      throw error;
    }
  }
}

module.exports = new ContactService();
