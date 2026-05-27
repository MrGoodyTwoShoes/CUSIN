const pool = require('../config/database');
const logger = require('../config/logger');

class NotificationService {
  constructor() {
    // In production, integrate with Firebase Cloud Messaging, Twilio, or similar
    this.pushEnabled = process.env.PUSH_NOTIFICATIONS_ENABLED === 'true';
    this.smsEnabled = process.env.SMS_NOTIFICATIONS_ENABLED === 'true';
  }

  // Send notification to a user
  async sendNotification(userId, notificationData) {
    try {
      const { type, title, message, data, priority = 'normal' } = notificationData;

      // Store notification in database
      const query = `
        INSERT INTO notifications (user_id, type, title, message, data, priority, status)
        VALUES ($1, $2, $3, $4, $5, $6, 'pending')
        RETURNING id
      `;
      const result = await pool.query(query, [
        userId,
        type,
        title,
        message,
        JSON.stringify(data || {}),
        priority
      ]);

      const notificationId = result.rows[0].id;

      // Send push notification if enabled
      if (this.pushEnabled) {
        await this.sendPushNotification(userId, {
          title,
          body: message,
          data: { ...data, notificationId }
        });
      }

      // Update notification status
      await pool.query(
        'UPDATE notifications SET status = $1 WHERE id = $2',
        ['sent', notificationId]
      );

      return { success: true, notificationId };
    } catch (error) {
      logger.error('Error sending notification:', error);
      throw error;
    }
  }

  // Send push notification (placeholder for FCM/OneSignal integration)
  async sendPushNotification(userId, pushData) {
    try {
      // In production, integrate with Firebase Cloud Messaging
      // For MVP, we'll log and return success
      logger.info(`Push notification to user ${userId}:`, pushData);
      
      // Example FCM integration:
      // const message = {
      //   notification: {
      //     title: pushData.title,
      //     body: pushData.body
      //   },
      //   data: pushData.data,
      //   token: await this.getUserFCMToken(userId)
      // };
      // await admin.messaging().send(message);
      
      return { success: true };
    } catch (error) {
      logger.error('Error sending push notification:', error);
      throw error;
    }
  }

  // Send SMS notification (placeholder for Twilio integration)
  async sendSMS(phoneNumber, message) {
    try {
      if (!this.smsEnabled) {
        logger.info(`SMS disabled. Would send to ${phoneNumber}: ${message}`);
        return { success: true };
      }

      // In production, integrate with Twilio
      // const client = twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
      // await client.messages.create({
      //   body: message,
      //   from: process.env.TWILIO_PHONE_NUMBER,
      //   to: phoneNumber
      // });

      logger.info(`SMS sent to ${phoneNumber}: ${message}`);
      return { success: true };
    } catch (error) {
      logger.error('Error sending SMS:', error);
      throw error;
    }
  }

  // Notify circle members about incident
  async notifyCircle(circleId, incidentData) {
    try {
      const circleService = require('./circleService');
      const members = await circleService.getMembers(circleId);

      const notificationPromises = members.map(member => {
        return this.sendNotification(member.user_id, {
          type: 'circle_incident',
          title: 'New Incident in Your Circle',
          message: `A new ${incidentData.incident_type} has been reported in your circle.`,
          data: {
            circleId,
            incidentId: incidentData.id,
            incidentType: incidentData.incident_type,
            severity: incidentData.severity
          },
          priority: incidentData.severity === 'critical' ? 'high' : 'normal'
        });
      });

      await Promise.all(notificationPromises);

      // Also send via WebSocket for real-time delivery
      if (global.websocketServer) {
        global.websocketServer.sendToCircle(circleId, {
          type: 'circle_incident',
          data: incidentData
        });
      }

      return { success: true, notifiedCount: members.length };
    } catch (error) {
      logger.error('Error notifying circle:', error);
      throw error;
    }
  }

  // Notify nearby users about incident
  async notifyNearbyUsers(h3Cell, incidentData) {
    try {
      // Get users subscribed to this area
      // This would require a user location/subscriptions table
      // For MVP, we'll use WebSocket area subscriptions

      if (global.websocketServer) {
        global.websocketServer.sendToNearbyUsers(h3Cell, {
          type: 'nearby_incident',
          data: incidentData
        });
      }

      return { success: true };
    } catch (error) {
      logger.error('Error notifying nearby users:', error);
      throw error;
    }
  }

  // Notify user about incident approval
  async notifyIncidentApproved(userId, incidentData) {
    try {
      await this.sendNotification(userId, {
        type: 'incident_approved',
        title: 'Your Incident Has Been Approved',
        message: `Your reported ${incidentData.incident_type} has been approved and is now visible on the heatmap.`,
        data: {
          incidentId: incidentData.id,
          incidentType: incidentData.incident_type
        },
        priority: 'normal'
      });

      return { success: true };
    } catch (error) {
      logger.error('Error notifying incident approval:', error);
      throw error;
    }
  }

  // Notify user about incident rejection
  async notifyIncidentRejected(userId, incidentData, reason) {
    try {
      await this.sendNotification(userId, {
        type: 'incident_rejected',
        title: 'Your Incident Was Not Approved',
        message: `Your reported ${incidentData.incident_type} was not approved. ${reason || ''}`,
        data: {
          incidentId: incidentData.id,
          incidentType: incidentData.incident_type,
          reason
        },
        priority: 'normal'
      });

      return { success: true };
    } catch (error) {
      logger.error('Error notifying incident rejection:', error);
      throw error;
    }
  }

  // Send emergency escalation notification
  async sendEmergencyEscalation(userId, incidentData, message) {
    try {
      const contactService = require('./contactService');
      const contacts = await contactService.getEmergencyContacts(userId);

      const smsPromises = contacts.map(contact => {
        return this.sendSMS(contact.contact_phone, message);
      });

      await Promise.all(smsPromises);

      // Also send push notification to user
      await this.sendNotification(userId, {
        type: 'emergency_escalation',
        title: 'Emergency Contacts Notified',
        message: 'Your emergency contacts have been notified about your situation.',
        data: {
          incidentId: incidentData.id,
          contactCount: contacts.length
        },
        priority: 'high'
      });

      return { success: true, notifiedCount: contacts.length };
    } catch (error) {
      logger.error('Error sending emergency escalation:', error);
      throw error;
    }
  }

  // Get user notifications
  async getUserNotifications(userId, filters = {}) {
    try {
      const { limit = 20, offset = 0, unread_only = false, type } = filters;

      let query = `
        SELECT id, type, title, message, data, priority, status, created_at, read_at
        FROM notifications
        WHERE user_id = $1
      `;
      const params = [userId];
      let paramIndex = 2;

      if (unread_only) {
        query += ` AND read_at IS NULL`;
      }

      if (type) {
        query += ` AND type = $${paramIndex++}`;
        params.push(type);
      }

      query += ` ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
      params.push(limit, offset);

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting user notifications:', error);
      throw error;
    }
  }

  // Mark notification as read
  async markAsRead(notificationId, userId) {
    try {
      const query = `
        UPDATE notifications
        SET read_at = NOW()
        WHERE id = $1 AND user_id = $2
        RETURNING id
      `;
      const result = await pool.query(query, [notificationId, userId]);

      if (result.rows.length === 0) {
        throw new Error('Notification not found');
      }

      return { success: true };
    } catch (error) {
      logger.error('Error marking notification as read:', error);
      throw error;
    }
  }

  // Mark all notifications as read for user
  async markAllAsRead(userId) {
    try {
      const query = `
        UPDATE notifications
        SET read_at = NOW()
        WHERE user_id = $1 AND read_at IS NULL
      `;
      await pool.query(query, [userId]);

      return { success: true };
    } catch (error) {
      logger.error('Error marking all notifications as read:', error);
      throw error;
    }
  }

  // Get unread notification count
  async getUnreadCount(userId) {
    try {
      const query = `
        SELECT COUNT(*) as count
        FROM notifications
        WHERE user_id = $1 AND read_at IS NULL
      `;
      const result = await pool.query(query, [userId]);
      return parseInt(result.rows[0].count);
    } catch (error) {
      logger.error('Error getting unread count:', error);
      throw error;
    }
  }
}

module.exports = new NotificationService();
