const pool = require('../config/database');
const logger = require('../config/logger');
const trustService = require('./trustService');

class ModerationService {
  async addToQueue(incidentId, priority = 'normal') {
    try {
      const query = `
        INSERT INTO moderation_queue (incident_id, priority)
        VALUES ($1, $2)
        RETURNING id
      `;
      const result = await pool.query(query, [incidentId, priority]);
      return result.rows[0];
    } catch (error) {
      logger.error('Error adding to moderation queue:', error);
      throw error;
    }
  }

  async getQueue(limit = 20, priority = null) {
    try {
      let query = `
        SELECT 
          mq.*,
          i.incident_type,
          i.description,
          i.severity,
          i.confidence_score,
          i.incident_time,
          u.display_name,
          u.trust_score
        FROM moderation_queue mq
        JOIN incidents i ON mq.incident_id = i.id
        JOIN users u ON i.user_id = u.id
        WHERE mq.status = 'pending'
      `;
      
      const params = [];
      if (priority) {
        query += ' AND mq.priority = $1';
        params.push(priority);
      }
      
      query += ' ORDER BY mq.created_at ASC LIMIT $' + (params.length + 1);
      params.push(limit);

      const result = await pool.query(query, params);
      return result.rows;
    } catch (error) {
      logger.error('Error getting moderation queue:', error);
      throw error;
    }
  }

  async approveIncident(queueId, moderatorId, notes = '') {
    try {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');

        // Get incident ID
        const queueResult = await client.query(
          'SELECT incident_id FROM moderation_queue WHERE id = $1',
          [queueId]
        );
        const incidentId = queueResult.rows[0].incident_id;

        // Update incident status
        await client.query(
          'UPDATE incidents SET status = $1, moderated_by = $2, moderated_at = NOW(), moderation_notes = $3 WHERE id = $4',
          ['approved', moderatorId, notes, incidentId]
        );

        // Update queue
        await client.query(
          'UPDATE moderation_queue SET status = $1, assigned_to = $2, reviewed_at = NOW() WHERE id = $3',
          ['reviewed', moderatorId, queueId]
        );

        // Get user ID for trust update
        const incidentResult = await client.query(
          'SELECT user_id, confidence_score FROM incidents WHERE id = $1',
          [incidentId]
        );
        const userId = incidentResult.rows[0].user_id;
        const confidenceScore = incidentResult.rows[0].confidence_score;

        // Apply trust reward
        await trustService.applyReportReward(userId, confidenceScore);

        await client.query('COMMIT');
        return { success: true };
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      logger.error('Error approving incident:', error);
      throw error;
    }
  }

  async rejectIncident(queueId, moderatorId, notes = '') {
    try {
      const client = await pool.connect();
      try {
        await client.query('BEGIN');

        // Get incident ID
        const queueResult = await client.query(
          'SELECT incident_id FROM moderation_queue WHERE id = $1',
          [queueId]
        );
        const incidentId = queueResult.rows[0].incident_id;

        // Update incident status
        await client.query(
          'UPDATE incidents SET status = $1, moderated_by = $2, moderated_at = NOW(), moderation_notes = $3 WHERE id = $4',
          ['rejected', moderatorId, notes, incidentId]
        );

        // Update queue
        await client.query(
          'UPDATE moderation_queue SET status = $1, assigned_to = $2, reviewed_at = NOW() WHERE id = $3',
          ['reviewed', moderatorId, queueId]
        );

        await client.query('COMMIT');
        return { success: true };
      } catch (error) {
        await client.query('ROLLBACK');
        throw error;
      } finally {
        client.release();
      }
    } catch (error) {
      logger.error('Error rejecting incident:', error);
      throw error;
    }
  }

  async aiTriage(incidentId) {
    try {
      // Simple AI triage - can be enhanced with actual ML models
      const incidentResult = await pool.query(
        'SELECT incident_type, severity, description FROM incidents WHERE id = $1',
        [incidentId]
      );
      const incident = incidentResult.rows[0];

      if (!incident) return null;

      // Determine priority based on incident type and severity
      const criticalTypes = ['violence', 'kidnapping'];
      const highTypes = ['robbery', 'harassment'];

      let priority = 'normal';
      let confidence = 0.7;

      if (criticalTypes.includes(incident.incident_type) || incident.severity === 'critical') {
        priority = 'critical';
        confidence = 0.9;
      } else if (highTypes.includes(incident.incident_type) || incident.severity === 'high') {
        priority = 'high';
        confidence = 0.8;
      }

      // Check for spam indicators
      if (this.detectSpam(incident)) {
        priority = 'low';
        confidence = 0.6;
      }

      const classification = {
        priority,
        confidence,
        categories: [incident.incident_type],
        severity: incident.severity,
      };

      // Update moderation queue with AI classification
      await pool.query(
        'UPDATE moderation_queue SET ai_classification = $1, ai_confidence = $2 WHERE incident_id = $3',
        [JSON.stringify(classification), confidence, incidentId]
      );

      return classification;
    } catch (error) {
      logger.error('Error in AI triage:', error);
      throw error;
    }
  }

  detectSpam(incident) {
    // Simple spam detection - can be enhanced
    const spamKeywords = ['test', 'spam', 'fake', 'xxx'];
    const description = incident.description?.toLowerCase() || '';
    return spamKeywords.some(keyword => description.includes(keyword));
  }
}

module.exports = new ModerationService();
