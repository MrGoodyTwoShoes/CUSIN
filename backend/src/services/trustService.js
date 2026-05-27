const pool = require('../config/database');
const logger = require('../config/logger');

class TrustService {
  async calculateTrustScore(userId) {
    try {
      const query = `
        SELECT 
          COUNT(*) as total_reports,
          SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved_reports,
          SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected_reports,
          AVG(confidence_score) as avg_confidence,
          MAX(created_at) as last_report
        FROM incidents
        WHERE user_id = $1
      `;
      const result = await pool.query(query, [userId]);
      const stats = result.rows[0];

      if (!stats.total_reports || stats.total_reports === 0) {
        return 50.00; // Neutral score for new users
      }

      // Calculate components
      const consistencyScore = this.calculateConsistency(stats);
      const reliabilityScore = this.calculateReliability(stats);
      const volumeScore = this.calculateVolume(stats);
      const recencyScore = this.calculateRecency(stats.last_report);

      // Weighted average
      const trustScore = (
        consistencyScore * 0.35 +
        reliabilityScore * 0.30 +
        volumeScore * 0.20 +
        recencyScore * 0.15
      );

      return Math.min(100, Math.max(0, trustScore));
    } catch (error) {
      logger.error('Error calculating trust score:', error);
      throw error;
    }
  }

  calculateConsistency(stats) {
    if (stats.total_reports === 0) return 50;
    const approvalRate = stats.approved_reports / stats.total_reports;
    return approvalRate * 100;
  }

  calculateReliability(stats) {
    if (!stats.avg_confidence) return 50;
    return stats.avg_confidence;
  }

  calculateVolume(stats) {
    // Reward users with more reports (up to a point)
    const volume = stats.total_reports;
    if (volume < 5) return 30;
    if (volume < 20) return 60;
    if (volume < 50) return 80;
    return 90;
  }

  calculateRecency(lastReport) {
    if (!lastReport) return 30;
    const daysSinceReport = (Date.now() - new Date(lastReport)) / (1000 * 60 * 60 * 24);
    if (daysSinceReport < 7) return 100;
    if (daysSinceReport < 30) return 80;
    if (daysSinceReport < 90) return 60;
    if (daysSinceReport < 180) return 40;
    return 20;
  }

  async recordTrustEvent(userId, eventType, scoreChange, reason, incidentId = null) {
    try {
      const previousScore = await this.getCurrentTrustScore(userId);
      const newScore = Math.min(100, Math.max(0, previousScore + scoreChange));

      const query = `
        INSERT INTO trust_events (user_id, event_type, score_change, previous_score, new_score, reason, related_incident_id)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id
      `;
      await pool.query(query, [userId, eventType, scoreChange, previousScore, newScore, reason, incidentId]);

      // Update user's trust score
      await pool.query(
        'UPDATE users SET trust_score = $1 WHERE id = $2',
        [newScore, userId]
      );

      return newScore;
    } catch (error) {
      logger.error('Error recording trust event:', error);
      throw error;
    }
  }

  async getCurrentTrustScore(userId) {
    try {
      const result = await pool.query(
        'SELECT trust_score FROM users WHERE id = $1',
        [userId]
      );
      return result.rows[0]?.trust_score || 50.00;
    } catch (error) {
      logger.error('Error getting current trust score:', error);
      return 50.00;
    }
  }

  async applyAbusePenalty(userId, severity) {
    const penalty = severity === 'severe' ? -30 : -15;
    return this.recordTrustEvent(userId, 'abuse_flagged', penalty, 'Abuse detected');
  }

  async applyReportReward(userId, confidenceScore) {
    const reward = confidenceScore * 0.1; // Small reward for contributing
    return this.recordTrustEvent(userId, 'report_approved', reward, 'Report approved and corroborated');
  }

  // IP Correlation Detection - NEW
  async detectIPCorrelation(userId, ipAddress) {
    try {
      // Check if this IP has been used by multiple accounts for similar actions
      const query = `
        SELECT 
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) as total_actions,
          array_agg(DISTINCT user_id) as user_ids
        FROM (
          SELECT user_id
          FROM incidents
          WHERE user_id != $1
            AND created_at >= NOW() - INTERVAL '24 hours'
          LIMIT 100
        ) as recent_users
        CROSS JOIN LATERAL (
          SELECT user_id
          FROM sessions
          WHERE ip_address = $2
            AND created_at >= NOW() - INTERVAL '7 days'
          LIMIT 50
        ) as ip_users
        WHERE recent_users.user_id = ip_users.user_id
      `;
      
      const result = await pool.query(query, [userId, ipAddress]);
      const row = result.rows[0];

      // If many users from same IP, flag as suspicious
      const correlationScore = row.unique_users > 5 ? 0.8 : 
                                row.unique_users > 3 ? 0.5 : 
                                row.unique_users > 1 ? 0.3 : 0;

      return {
        isCorrelated: correlationScore > 0.5,
        correlationScore,
        uniqueUsers: row.unique_users,
        totalActions: row.total_actions,
        userIds: row.user_ids,
      };
    } catch (error) {
      logger.error('Error detecting IP correlation:', error);
      return { isCorrelated: false, correlationScore: 0 };
    }
  }

  // Check for rapid trust score changes - NEW
  async detectRapidTrustChange(userId) {
    try {
      const query = `
        SELECT 
          COUNT(*) as changes,
          SUM(ABS(score_change)) as total_change,
          MAX(created_at) as last_change
        FROM trust_events
        WHERE 
          user_id = $1
          AND created_at >= NOW() - INTERVAL '24 hours'
      `;
      const result = await pool.query(query, [userId]);
      const row = result.rows[0];

      // Flag if more than 3 changes or total change > 20 in 24 hours
      const isRapid = row.changes >= 3 || row.total_change >= 20;

      return {
        isRapid,
        changes: row.changes,
        totalChange: row.total_change,
        lastChange: row.last_change,
      };
    } catch (error) {
      logger.error('Error detecting rapid trust change:', error);
      return { isRapid: false };
    }
  }

  // Apply accelerated trust decay for suspicious accounts - NEW
  async applyAcceleratedDecay(userId, reason) {
    try {
      const currentScore = await this.getCurrentTrustScore(userId);
      // Decay by 50% for suspicious accounts (was gradual)
      const decayAmount = currentScore * 0.5;
      
      return this.recordTrustEvent(
        userId,
        'accelerated_decay',
        -decayAmount,
        reason || 'Suspicious activity detected - accelerated trust decay'
      );
    } catch (error) {
      logger.error('Error applying accelerated decay:', error);
      throw error;
    }
  }

  // Check trust score cap for new accounts - NEW
  async enforceTrustScoreCap(userId, maxScore = 90) {
    try {
      const currentScore = await this.getCurrentTrustScore(userId);
      
      // Check account age
      const userResult = await pool.query(
        'SELECT created_at FROM users WHERE id = $1',
        [userId]
      );
      const createdAt = userResult.rows[0]?.created_at;
      
      if (!createdAt) return currentScore;
      
      const accountAgeDays = (Date.now() - new Date(createdAt)) / (1000 * 60 * 60 * 24);
      
      // Cap trust score for accounts less than 30 days old
      if (accountAgeDays < 30 && currentScore > maxScore) {
        await pool.query(
          'UPDATE users SET trust_score = $1 WHERE id = $2',
          [maxScore, userId]
        );
        return maxScore;
      }
      
      return currentScore;
    } catch (error) {
      logger.error('Error enforcing trust score cap:', error);
      return 50;
    }
  }
}

module.exports = new TrustService();
