const pool = require('../config/database');
const geoService = require('./geoService');
const logger = require('../config/logger');

class CircleService {
  async createCircle(userId, circleData) {
    try {
      const { name, description, circle_type, boundary_coordinates, is_private } = circleData;

      // Rate limit circle creation - max 3 circles per day
      const creationCheck = await this.checkCircleCreationRate(userId);
      if (creationCheck.exceeded) {
        throw new Error('Circle creation rate limit exceeded');
      }

      // Convert boundary to PostGIS polygon if provided
      let boundary = null;
      if (boundary_coordinates && boundary_coordinates.length >= 3) {
        const polygonText = boundary_coordinates
          .map(coord => `${coord.lng} ${coord.lat}`)
          .join(',');
        boundary = `ST_PolygonFromText('POLYGON((${polygonText}, ${boundary_coordinates[0].lng} ${boundary_coordinates[0].lat}))', 4326)`;
      }

      const query = `
        INSERT INTO circles (name, description, creator_id, circle_type, boundary, is_private)
        VALUES ($1, $2, $3, $4, ${boundary ? boundary : 'NULL'}, $5)
        RETURNING id, name, description, circle_type, is_private, created_at
      `;

      const result = await pool.query(query, [name, description, userId, circle_type || 'community', is_private !== false]);
      const circle = result.rows[0];

      // Add creator as admin member
      await this.addMember(circle.id, userId, 'admin');

      return circle;
    } catch (error) {
      logger.error('Error creating circle:', error);
      throw error;
    }
  }

  // Check circle creation rate limit - NEW
  async checkCircleCreationRate(userId) {
    try {
      const query = `
        SELECT COUNT(*) as count
        FROM circles
        WHERE 
          creator_id = $1
          AND created_at >= NOW() - INTERVAL '24 hours'
      `;
      const result = await pool.query(query, [userId]);
      const count = parseInt(result.rows[0].count);

      return {
        count,
        limit: 3,
        exceeded: count >= 3,
      };
    } catch (error) {
      logger.error('Error checking circle creation rate:', error);
      return { exceeded: false };
    }
  }

  async getCircles(userId, filters = {}) {
    try {
      const { circle_type, is_member } = filters;
      
      let query = `
        SELECT c.*, 
          COALESCE(cm.role, 'none') as user_role,
          CASE 
            WHEN c.is_private = true THEN NULL
            ELSE c.member_count
          END as member_count
        FROM circles c
        LEFT JOIN circle_members cm ON c.id = cm.circle_id AND cm.user_id = $1
        WHERE 1=1
      `;
      const params = [userId];

      if (circle_type) {
        query += ` AND c.circle_type = $${params.length + 1}`;
        params.push(circle_type);
      }

      if (is_member === 'true') {
        query += ` AND cm.user_id = $1`;
      }

      if (is_member === 'false') {
        query += ` AND (c.is_private = false OR cm.user_id IS NULL)`;
      }

      query += ' ORDER BY c.created_at DESC';

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting circles:', error);
      throw error;
    }
  }

  async getCircleById(circleId, userId) {
    try {
      const query = `
        SELECT c.*,
          COALESCE(cm.role, 'none') as user_role,
          COALESCE(cm.trust_in_circle, 50) as trust_in_circle
        FROM circles c
        LEFT JOIN circle_members cm ON c.id = cm.circle_id AND cm.user_id = $2
        WHERE c.id = $1
      `;
      const result = await pool.query(query, [circleId, userId]);
      
      if (result.rows.length === 0) {
        return null;
      }

      const circle = result.rows[0];

      // Check privacy
      if (circle.is_private && circle.user_role === 'none') {
        throw new Error('Access denied to private circle');
      }

      return circle;
    } catch (error) {
      logger.error('Error getting circle:', error);
      throw error;
    }
  }

  async addMember(circleId, userId, role = 'member') {
    try {
      const query = `
        INSERT INTO circle_members (circle_id, user_id, role)
        VALUES ($1, $2, $3)
        ON CONFLICT (circle_id, user_id) 
        DO UPDATE SET role = $3
        RETURNING id
      `;
      
      await pool.query(query, [circleId, userId, role]);

      // Update member count
      await pool.query(
        'UPDATE circles SET member_count = member_count + 1 WHERE id = $1',
        [circleId]
      );

      return { success: true };
    } catch (error) {
      logger.error('Error adding member:', error);
      throw error;
    }
  }

  async removeMember(circleId, userId) {
    try {
      const query = `
        DELETE FROM circle_members 
        WHERE circle_id = $1 AND user_id = $2
        RETURNING id
      `;
      
      const result = await pool.query(query, [circleId, userId]);

      if (result.rows.length > 0) {
        // Update member count
        await pool.query(
          'UPDATE circles SET member_count = member_count - 1 WHERE id = $1',
          [circleId]
        );
      }

      return { success: true };
    } catch (error) {
      logger.error('Error removing member:', error);
      throw error;
    }
  }

  async getMembers(circleId, requestingUserId = null) {
    try {
      // Check if circle is private and requesting user is member
      if (requestingUserId) {
        const circle = await this.getCircleById(circleId, requestingUserId);
        if (!circle) {
          throw new Error('Access denied');
        }
      }

      // Only return member count for privacy, not full member list
      const query = `
        SELECT COUNT(*) as member_count
        FROM circle_members
        WHERE circle_id = $1
      `;
      const result = await pool.query(query, [circleId]);
      
      return {
        member_count: parseInt(result.rows[0].member_count),
        members: [], // Empty array - full member list not exposed
        privacy_note: 'Full member list hidden for privacy protection',
      };
    } catch (error) {
      logger.error('Error getting members:', error);
      throw error;
    }
  }

  // Get member list only for admins - NEW
  async getMemberListForAdmin(circleId, requestingUserId) {
    try {
      // Verify requesting user is admin
      const memberCheck = await pool.query(
        'SELECT role FROM circle_members WHERE circle_id = $1 AND user_id = $2',
        [circleId, requestingUserId]
      );

      if (memberCheck.rows.length === 0 || memberCheck.rows[0].role !== 'admin') {
        throw new Error('Access denied - admin only');
      }

      const query = `
        SELECT cm.id, cm.role, cm.joined_at, 
          u.display_name, u.trust_score
        FROM circle_members cm
        JOIN users u ON cm.user_id = u.id
        WHERE cm.circle_id = $1
        ORDER BY 
          CASE cm.role 
            WHEN 'admin' THEN 1 
            WHEN 'moderator' THEN 2 
            ELSE 3 
          END,
          cm.joined_at ASC
      `;
      const result = await pool.query(query, [circleId]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting member list:', error);
      throw error;
    }
  }

  // Detect circle enumeration attempts - NEW
  async detectEnumeration(userId, circleId) {
    try {
      // Log circle access for enumeration detection
      const query = `
        INSERT INTO circle_access_logs (circle_id, user_id, accessed_at)
        VALUES ($1, $2, NOW())
        ON CONFLICT (circle_id, user_id) 
        DO UPDATE SET access_count = circle_access_logs.access_count + 1, accessed_at = NOW()
        RETURNING access_count
      `;
      
      // Note: This assumes circle_access_logs table exists
      // For now, return false since table may not exist
      return { isEnumeration: false };
    } catch (error) {
      logger.error('Error detecting enumeration:', error);
      return { isEnumeration: false };
    }
  }

  async updateMemberRole(circleId, userId, role) {
    try {
      const query = `
        UPDATE circle_members 
        SET role = $1
        WHERE circle_id = $2 AND user_id = $3
        RETURNING id
      `;
      await pool.query(query, [role, circleId, userId]);
      return { success: true };
    } catch (error) {
      logger.error('Error updating member role:', error);
      throw error;
    }
  }

  async getCircleIncidents(circleId, userId, limit = 50) {
    try {
      // Check if user is member
      const circle = await this.getCircleById(circleId, userId);
      if (!circle || circle.user_role === 'none') {
        throw new Error('Access denied');
      }

      // Get members
      const members = await this.getMembers(circleId);
      const memberIds = members.map(m => m.user_id);

      const query = `
        SELECT 
          id, incident_type, description, severity, confidence_score,
          ST_X(fuzzed_location) as longitude, ST_Y(fuzzed_location) as latitude,
          h3_cell, status, incident_time, created_at
        FROM incidents
        WHERE 
          user_id = ANY($1)
          AND status = 'approved'
        ORDER BY incident_time DESC
        LIMIT $2
      `;
      const result = await pool.query(query, [memberIds, limit]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting circle incidents:', error);
      throw error;
    }
  }

  async notifyCircle(circleId, notificationData) {
    try {
      const members = await this.getMembers(circleId);
      const memberIds = members.map(m => m.user_id);

      // This would integrate with notification service
      // For now, return the list of members to notify
      return {
        circleId,
        notificationData,
        recipients: memberIds,
        recipientCount: memberIds.length
      };
    } catch (error) {
      logger.error('Error notifying circle:', error);
      throw error;
    }
  }

  async isUserInCircle(circleId, userId) {
    try {
      const result = await pool.query(
        'SELECT id FROM circle_members WHERE circle_id = $1 AND user_id = $2',
        [circleId, userId]
      );
      return result.rows.length > 0;
    } catch (error) {
      logger.error('Error checking circle membership:', error);
      return false;
    }
  }

  async getUserCircles(userId) {
    try {
      const query = `
        SELECT c.*, cm.role, cm.trust_in_circle
        FROM circles c
        JOIN circle_members cm ON c.id = cm.circle_id
        WHERE cm.user_id = $1
        ORDER BY cm.joined_at DESC
      `;
      const result = await pool.query(query, [userId]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting user circles:', error);
      throw error;
    }
  }
}

module.exports = new CircleService();
