const pool = require('../config/database');
const logger = require('../config/logger');

class AuditService {
  async logAuditEntry(auditData) {
    try {
      const {
        user_id,
        action,
        resource_type,
        resource_id,
        old_values,
        new_values,
        ip_address,
        user_agent
      } = auditData;

      const query = `
        INSERT INTO audit_logs (user_id, action, resource_type, resource_id, old_values, new_values, ip_address, user_agent)
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING id, created_at
      `;

      const result = await pool.query(query, [
        user_id || null,
        action,
        resource_type || null,
        resource_id || null,
        old_values ? JSON.stringify(old_values) : null,
        new_values ? JSON.stringify(new_values) : null,
        ip_address || null,
        user_agent || null
      ]);

      logger.info(`Audit log created: ${action} on ${resource_type}`, {
        audit_id: result.rows[0].id,
        user_id,
        resource_id
      });

      return result.rows[0];
    } catch (error) {
      logger.error('Error creating audit log:', error);
      // Don't throw - audit failures shouldn't break the main flow
      return null;
    }
  }

  async getAuditLogs(filters = {}) {
    try {
      const {
        user_id,
        action,
        resource_type,
        resource_id,
        limit = 100,
        offset = 0,
        start_date,
        end_date
      } = filters;

      let query = `
        SELECT id, user_id, action, resource_type, resource_id, old_values, new_values, ip_address, user_agent, created_at
        FROM audit_logs
        WHERE 1=1
      `;
      const params = [];
      let paramIndex = 1;

      if (user_id) {
        query += ` AND user_id = $${paramIndex++}`;
        params.push(user_id);
      }

      if (action) {
        query += ` AND action = $${paramIndex++}`;
        params.push(action);
      }

      if (resource_type) {
        query += ` AND resource_type = $${paramIndex++}`;
        params.push(resource_type);
      }

      if (resource_id) {
        query += ` AND resource_id = $${paramIndex++}`;
        params.push(resource_id);
      }

      if (start_date) {
        query += ` AND created_at >= $${paramIndex++}`;
        params.push(start_date);
      }

      if (end_date) {
        query += ` AND created_at <= $${paramIndex++}`;
        params.push(end_date);
      }

      query += ` ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
      params.push(limit, offset);

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting audit logs:', error);
      throw error;
    }
  }

  async getUserActivityHistory(userId, limit = 50) {
    try {
      const query = `
        SELECT 
          action,
          resource_type,
          COUNT(*) as action_count,
          MAX(created_at) as last_action,
          MIN(created_at) as first_action
        FROM audit_logs
        WHERE user_id = $1
        GROUP BY action, resource_type
        ORDER BY action_count DESC
        LIMIT $2
      `;
      const result = await pool.query(query, [userId, limit]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting user activity history:', error);
      throw error;
    }
  }

  async getResourceHistory(resource_type, resource_id, limit = 50) {
    try {
      const query = `
        SELECT id, user_id, action, old_values, new_values, ip_address, user_agent, created_at
        FROM audit_logs
        WHERE resource_type = $1 AND resource_id = $2
        ORDER BY created_at DESC
        LIMIT $3
      `;
      const result = await pool.query(query, [resource_type, resource_id, limit]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting resource history:', error);
      throw error;
    }
  }

  async getAuditStats(filters = {}) {
    try {
      const { start_date, end_date } = filters;

      let dateFilter = '';
      const params = [];
      let paramIndex = 1;

      if (start_date) {
        dateFilter += ` AND created_at >= $${paramIndex++}`;
        params.push(start_date);
      }

      if (end_date) {
        dateFilter += ` AND created_at <= $${paramIndex++}`;
        params.push(end_date);
      }

      const query = `
        SELECT 
          action,
          resource_type,
          COUNT(*) as count,
          COUNT(DISTINCT user_id) as unique_users
        FROM audit_logs
        WHERE 1=1 ${dateFilter}
        GROUP BY action, resource_type
        ORDER BY count DESC
      `;

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting audit stats:', error);
      throw error;
    }
  }

  // Middleware helper to auto-log actions
  static createAuditMiddleware(action, resource_type) {
    return async (req, res, next) => {
      // Store original json
      const originalJson = res.json;

      // Override json to capture response
      res.json = function(data) {
        // Log the action
        const auditService = new AuditService();
        auditService.logAuditEntry({
          user_id: req.user?.id,
          action,
          resource_type,
          resource_id: req.params?.id || req.body?.id,
          old_values: req.body, // For updates, this would need more logic
          new_values: data,
          ip_address: req.ip,
          user_agent: req.get('user-agent')
        }).catch(err => {
          // Silent fail
        });

        // Call original json
        return originalJson.call(this, data);
      };

      next();
    };
  }
}

module.exports = new AuditService();
