const pool = require('../config/database');
const crypto = require('crypto');
const logger = require('../config/logger');

class DeduplicationService {
  // Generate a hash for an incident to detect duplicates
  generateIncidentHash(incidentData) {
    const { incident_type, latitude, longitude, description, user_id } = incidentData;
    
    // Normalize data for hashing
    const normalized = {
      type: incident_type.toLowerCase().trim(),
      // Fuzz location to 100m precision for duplicate detection
      lat: Math.round(latitude * 1000) / 1000,
      lng: Math.round(longitude * 1000) / 1000,
      // Normalize description (remove extra spaces, lowercase)
      desc: description ? description.toLowerCase().replace(/\s+/g, ' ').trim() : '',
      // Time window is handled separately
    };

    const hashString = JSON.stringify(normalized);
    return crypto.createHash('sha256').update(hashString).digest('hex');
  }

  // Check if incident is a duplicate
  async checkDuplicate(incidentData, timeWindowMinutes = 30) {
    try {
      const hash = this.generateIncidentHash(incidentData);
      const { latitude, longitude, user_id } = incidentData;

      // Check for exact hash match
      const hashQuery = `
        SELECT id, incident_type, description, created_at, user_id
        FROM incidents
        WHERE 
          incident_hash = $1
          AND created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
        ORDER BY created_at DESC
        LIMIT 1
      `;
      const hashResult = await pool.query(hashQuery, [hash]);
      
      if (hashResult.rows.length > 0) {
        return {
          is_duplicate: true,
          duplicate_type: 'exact',
          existing_incident: hashResult.rows[0],
          confidence: 0.95
        };
      }

      // Check for spatial-temporal duplicates (nearby similar incidents)
      const spatialQuery = `
        SELECT id, incident_type, description, created_at, user_id,
          ST_Distance(
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            location
          ) as distance_meters
        FROM incidents
        WHERE 
          incident_type = $3
          AND ST_Distance(
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            location
          ) < 200  -- Within 200 meters
          AND created_at >= NOW() - INTERVAL '${timeWindowMinutes} minutes'
          AND user_id != $4
        ORDER BY created_at DESC
        LIMIT 5
      `;
      const spatialResult = await pool.query(spatialQuery, [
        latitude,
        longitude,
        incidentData.incident_type,
        user_id
      ]);

      if (spatialResult.rows.length > 0) {
        // Check description similarity
        const similarIncident = spatialResult.rows[0];
        const descriptionSimilarity = this.calculateDescriptionSimilarity(
          incidentData.description,
          similarIncident.description
        );

        if (descriptionSimilarity > 0.7) {
          return {
            is_duplicate: true,
            duplicate_type: 'spatial_temporal',
            existing_incident: similarIncident,
            confidence: 0.8 + (descriptionSimilarity * 0.1),
            distance_meters: similarIncident.distance_meters
          };
        }
      }

      return { is_duplicate: false };
    } catch (error) {
      logger.error('Error checking duplicate:', error);
      return { is_duplicate: false }; // Fail open - don't block on dedup errors
    }
  }

  // Calculate similarity between two descriptions (simple Jaccard similarity)
  calculateDescriptionSimilarity(desc1, desc2) {
    if (!desc1 || !desc2) return 0;

    const words1 = new Set(desc1.toLowerCase().split(/\s+/));
    const words2 = new Set(desc2.toLowerCase().split(/\s+/));

    const intersection = new Set([...words1].filter(x => words2.has(x)));
    const union = new Set([...words1, ...words2]);

    return intersection.size / union.size;
  }

  // Store incident hash for future deduplication
  async storeIncidentHash(incidentId, incidentData) {
    try {
      const hash = this.generateIncidentHash(incidentData);
      
      await pool.query(
        'UPDATE incidents SET incident_hash = $1 WHERE id = $2',
        [hash, incidentId]
      );

      return { success: true };
    } catch (error) {
      logger.error('Error storing incident hash:', error);
      return { success: false };
    }
  }

  // Find similar incidents for corroboration
  async findSimilarIncidents(incidentData, timeWindowHours = 24, radiusMeters = 500) {
    try {
      const { latitude, longitude, incident_type } = incidentData;

      const query = `
        SELECT id, incident_type, description, severity, confidence_score,
          ST_X(fuzzed_location) as longitude, ST_Y(fuzzed_location) as latitude,
          created_at, user_id,
          ST_Distance(
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            location
          ) as distance_meters
        FROM incidents
        WHERE 
          incident_type = $3
          AND ST_Distance(
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            location
          ) < $4
          AND created_at >= NOW() - INTERVAL '${timeWindowHours} hours'
          AND status = 'approved'
        ORDER BY distance_meters ASC, created_at DESC
        LIMIT 10
      `;

      const result = await pool.query(query, [
        latitude,
        longitude,
        incident_type,
        radiusMeters
      ]);

      return result.rows;
    } catch (error) {
      logger.error('Error finding similar incidents:', error);
      return [];
    }
  }

  // Cluster similar incidents for heatmap aggregation
  async clusterSimilarIncidents(timeWindowHours = 24) {
    try {
      const query = `
        SELECT 
          incident_type,
          COUNT(*) as cluster_size,
          AVG(confidence_score) as avg_confidence,
          MAX(severity) as max_severity,
          array_agg(id) as incident_ids,
          ST_Centroid(ST_Collect(location)) as centroid
        FROM incidents
        WHERE 
          created_at >= NOW() - INTERVAL '${timeWindowHours} hours'
          AND status = 'approved'
        GROUP BY incident_type
        HAVING COUNT(*) >= 2
        ORDER BY cluster_size DESC
      `;

      const result = await pool.query(query);
      return result.rows;
    } catch (error) {
      logger.error('Error clustering similar incidents:', error);
      return [];
    }
  }

  // Clean up old hashes (to prevent hash collision attacks)
  async cleanupOldHashes(daysToKeep = 90) {
    try {
      const query = `
        UPDATE incidents
        SET incident_hash = NULL
        WHERE created_at < NOW() - INTERVAL '${daysToKeep} days'
        AND incident_hash IS NOT NULL
      `;

      const result = await pool.query(query);
      logger.info(`Cleaned up ${result.rowCount} old incident hashes`);
      
      return { success: true, cleaned_count: result.rowCount };
    } catch (error) {
      logger.error('Error cleaning up old hashes:', error);
      return { success: false };
    }
  }
}

module.exports = new DeduplicationService();
