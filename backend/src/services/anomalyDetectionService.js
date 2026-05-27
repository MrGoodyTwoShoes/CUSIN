const pool = require('../config/database');
const logger = require('../config/logger');

class AnomalyDetectionService {
  // Detect spam patterns
  async detectSpam(userId, incidentData) {
    try {
      const indicators = [];
      let spamScore = 0;

      // Check for rapid reporting (rate limit)
      const rapidReporting = await this.checkRapidReporting(userId, 5, 60); // 5 reports in 60 minutes
      if (rapidReporting.isSpam) {
        indicators.push({ type: 'rapid_reporting', score: 30, details: rapidReporting });
        spamScore += 30;
      }

      // Check for duplicate content
      const duplicateContent = await this.checkDuplicateContent(userId, incidentData.description);
      if (duplicateContent.isDuplicate) {
        indicators.push({ type: 'duplicate_content', score: 25, details: duplicateContent });
        spamScore += 25;
      }

      // Check for suspicious keywords
      const suspiciousKeywords = this.checkSuspiciousKeywords(incidentData.description);
      if (suspiciousKeywords.found) {
        indicators.push({ type: 'suspicious_keywords', score: 20, details: suspiciousKeywords });
        spamScore += 20;
      }

      // Check for low effort reports
      const lowEffort = this.checkLowEffort(incidentData);
      if (lowEffort.isLowEffort) {
        indicators.push({ type: 'low_effort', score: 15, details: lowEffort });
        spamScore += 15;
      }

      return {
        isSpam: spamScore >= 50,
        spamScore,
        indicators,
        severity: spamScore >= 70 ? 'high' : spamScore >= 50 ? 'medium' : 'low'
      };
    } catch (error) {
      logger.error('Error detecting spam:', error);
      return { isSpam: false, spamScore: 0, indicators: [] };
    }
  }

  // Check for rapid reporting
  async checkRapidReporting(userId, maxReports, timeWindowMinutes) {
    try {
      const query = `
        SELECT COUNT(*) as count
        FROM incidents
        WHERE 
          user_id = $1
          AND created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
      `;
      const result = await pool.query(query, [userId]);
      const count = parseInt(result.rows[0].count);

      return {
        isSpam: count >= maxReports,
        count,
        maxReports,
        timeWindowMinutes
      };
    } catch (error) {
      logger.error('Error checking rapid reporting:', error);
      return { isSpam: false };
    }
  }

  // Check for duplicate content from same user
  async checkDuplicateContent(userId, description) {
    try {
      if (!description) return { isDuplicate: false };

      const query = `
        SELECT id, description, created_at
        FROM incidents
        WHERE 
          user_id = $1
          AND description IS NOT NULL
          AND created_at >= NOW() - INTERVAL '24 hours'
        ORDER BY created_at DESC
        LIMIT 10
      `;
      const result = await pool.query(query, [userId]);

      for (const incident of result.rows) {
        const similarity = this.calculateSimilarity(description, incident.description);
        if (similarity > 0.85) {
          return {
            isDuplicate: true,
            similarIncidentId: incident.id,
            similarity,
            createdAt: incident.created_at
          };
        }
      }

      return { isDuplicate: false };
    } catch (error) {
      logger.error('Error checking duplicate content:', error);
      return { isDuplicate: false };
    }
  }

  // Calculate text similarity (simple Jaccard)
  calculateSimilarity(text1, text2) {
    if (!text1 || !text2) return 0;
    const words1 = new Set(text1.toLowerCase().split(/\s+/));
    const words2 = new Set(text2.toLowerCase().split(/\s+/));
    const intersection = new Set([...words1].filter(x => words2.has(x)));
    const union = new Set([...words1, ...words2]);
    return union.size === 0 ? 0 : intersection.size / union.size;
  }

  // Check for suspicious keywords
  checkSuspiciousKeywords(description) {
    if (!description) return { found: false };

    const spamKeywords = ['test', 'spam', 'fake', 'xxx', 'asdf', 'qwerty', 'hello world'];
    const lowerDesc = description.toLowerCase();
    
    const foundKeywords = spamKeywords.filter(keyword => lowerDesc.includes(keyword));
    
    return {
      found: foundKeywords.length > 0,
      keywords: foundKeywords
    };
  }

  // Check for low effort reports
  checkLowEffort(incidentData) {
    const { description, incident_type } = incidentData;
    
    // Very short description
    if (description && description.length < 10) {
      return { isLowEffort: true, reason: 'description_too_short' };
    }

    // Generic description
    const genericDescriptions = ['test', 'something happened', 'incident', 'help'];
    if (description && genericDescriptions.includes(description.toLowerCase().trim())) {
      return { isLowEffort: true, reason: 'generic_description' };
    }

    return { isLowEffort: false };
  }

  // Detect coordinated manipulation
  async detectCoordinatedManipulation(incidentData) {
    try {
      const { latitude, longitude, incident_type, description } = incidentData;
      const indicators = [];
      let manipulationScore = 0;

      // Check for multiple reports from same location in short time
      const locationCluster = await this.checkLocationCluster(latitude, longitude, incident_type, 15, 10);
      if (locationCluster.isClustered) {
        indicators.push({ type: 'location_cluster', score: 25, details: locationCluster });
        manipulationScore += 25;
      }

      // Check for similar descriptions from different users
      const descriptionCluster = await this.checkDescriptionCluster(description, 30);
      if (descriptionCluster.isClustered) {
        indicators.push({ type: 'description_cluster', score: 30, details: descriptionCluster });
        manipulationScore += 30;
      }

      // Check for device fingerprint correlation
      const deviceCorrelation = await this.checkDeviceCorrelation(latitude, longitude, 30);
      if (deviceCorrelation.isCorrelated) {
        indicators.push({ type: 'device_correlation', score: 35, details: deviceCorrelation });
        manipulationScore += 35;
      }

      return {
        isManipulation: manipulationScore >= 50,
        manipulationScore,
        indicators,
        severity: manipulationScore >= 70 ? 'high' : manipulationScore >= 50 ? 'medium' : 'low'
      };
    } catch (error) {
      logger.error('Error detecting coordinated manipulation:', error);
      return { isManipulation: false, manipulationScore: 0, indicators: [] };
    }
  }

  // Check for location clustering
  async checkLocationCluster(lat, lng, incidentType, radiusMeters, timeWindowMinutes) {
    try {
      const query = `
        SELECT COUNT(*) as count, COUNT(DISTINCT user_id) as unique_users
        FROM incidents
        WHERE 
          incident_type = $1
          AND ST_Distance(
            ST_SetSRID(ST_MakePoint($3, $2), 4326),
            location
          ) < $4
          AND created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
          AND status = 'pending'
      `;
      const result = await pool.query(query, [incidentType, lat, lng, radiusMeters]);
      const row = result.rows[0];

      return {
        isClustered: row.count >= 3 && row.unique_users >= 2,
        count: row.count,
        uniqueUsers: row.unique_users,
        radiusMeters,
        timeWindowMinutes
      };
    } catch (error) {
      logger.error('Error checking location cluster:', error);
      return { isClustered: false };
    }
  }

  // Check for description clustering
  async checkDescriptionCluster(description, timeWindowMinutes) {
    try {
      if (!description) return { isClustered: false };

      const query = `
        SELECT COUNT(*) as count, COUNT(DISTINCT user_id) as unique_users
        FROM incidents
        WHERE 
          description IS NOT NULL
          AND created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
          AND status = 'pending'
      `;
      const result = await pool.query(query);
      const incidents = result.rows;

      let similarCount = 0;
      let uniqueUsers = new Set();

      // This would need to fetch actual descriptions and compare
      // For MVP, we'll use a simplified approach

      return {
        isClustered: similarCount >= 3,
        count: similarCount,
        uniqueUsers: uniqueUsers.size
      };
    } catch (error) {
      logger.error('Error checking description cluster:', error);
      return { isClustered: false };
    }
  }

  // Check for device fingerprint correlation
  async checkDeviceCorrelation(lat, lng, timeWindowMinutes) {
    try {
      const query = `
        SELECT COUNT(*) as count, COUNT(DISTINCT device_fingerprint) as unique_devices
        FROM incidents i
        JOIN users u ON i.user_id = u.id
        WHERE 
          ST_Distance(
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            i.location
          ) < 200
          AND i.created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
          AND u.device_fingerprint IS NOT NULL
      `;
      const result = await pool.query(query, [lat, lng]);
      const row = result.rows[0];

      // If many reports from few devices, suspicious
      const ratio = row.unique_devices > 0 ? row.count / row.unique_devices : 0;

      return {
        isCorrelated: ratio >= 3,
        count: row.count,
        uniqueDevices: row.unique_devices,
        ratio
      };
    } catch (error) {
      logger.error('Error checking device correlation:', error);
      return { isCorrelated: false };
    }
  }

  // Flag anomaly in database
  async flagAnomaly(anomalyData) {
    try {
      const {
        user_id,
        incident_id,
        flag_type,
        severity,
        description,
        metadata
      } = anomalyData;

      const query = `
        INSERT INTO anomaly_flags (user_id, incident_id, flag_type, severity, description, metadata)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING id
      `;
      const result = await pool.query(query, [
        user_id || null,
        incident_id || null,
        flag_type,
        severity || 'medium',
        description,
        JSON.stringify(metadata || {})
      ]);

      logger.warn(`Anomaly flagged: ${flag_type} for user ${user_id}`, {
        anomaly_id: result.rows[0].id,
        incident_id
      });

      return { success: true, anomalyId: result.rows[0].id };
    } catch (error) {
      logger.error('Error flagging anomaly:', error);
      throw error;
    }
  }

  // Get anomalies for user
  async getUserAnomalies(userId, limit = 20) {
    try {
      const query = `
        SELECT id, flag_type, severity, description, metadata, resolved, created_at
        FROM anomaly_flags
        WHERE user_id = $1
        ORDER BY created_at DESC
        LIMIT $2
      `;
      const result = await pool.query(query, [userId, limit]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting user anomalies:', error);
      throw error;
    }
  }

  // Resolve anomaly
  async resolveAnomaly(anomalyId, resolvedBy, notes) {
    try {
      const query = `
        UPDATE anomaly_flags
        SET resolved = true, resolved_by = $2, resolved_at = NOW()
        WHERE id = $1
        RETURNING id
      `;
      const result = await pool.query(query, [anomalyId, resolvedBy]);

      if (result.rows.length === 0) {
        throw new Error('Anomaly not found');
      }

      return { success: true };
    } catch (error) {
      logger.error('Error resolving anomaly:', error);
      throw error;
    }
  }
}

module.exports = new AnomalyDetectionService();
