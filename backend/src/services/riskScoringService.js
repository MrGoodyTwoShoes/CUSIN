const pool = require('../config/database');
const logger = require('../config/logger');

class RiskScoringService {
  // Calculate comprehensive risk score for an incident
  async calculateIncidentRisk(incidentId) {
    try {
      // Get incident data
      const incidentQuery = `
        SELECT 
          i.*,
          u.trust_score as reporter_trust,
          COUNT(DISTINCT c.user_id) as corroboration_count
        FROM incidents i
        LEFT JOIN users u ON i.user_id = u.id
        LEFT JOIN jsonb_array_elements(i.corroborations) c ON true
        WHERE i.id = $1
        GROUP BY i.id, u.trust_score
      `;
      const incidentResult = await pool.query(incidentQuery, [incidentId]);
      
      if (incidentResult.rows.length === 0) {
        throw new Error('Incident not found');
      }

      const incident = incidentResult.rows[0];

      // Calculate risk components
      const confidenceScore = this.calculateConfidenceScore(incident);
      const severityScore = this.calculateSeverityScore(incident);
      const temporalScore = this.calculateTemporalScore(incident);
      const spatialScore = await this.calculateSpatialScore(incident);
      const corroborationScore = this.calculateCorroborationScore(incident);

      // Weighted average
      const riskScore = (
        confidenceScore * 0.25 +
        severityScore * 0.30 +
        temporalScore * 0.15 +
        spatialScore * 0.15 +
        corroborationScore * 0.15
      );

      return {
        incidentId,
        overall_risk_score: Math.min(100, Math.max(0, riskScore)),
        risk_level: this.getRiskLevel(riskScore),
        components: {
          confidence: confidenceScore,
          severity: severityScore,
          temporal: temporalScore,
          spatial: spatialScore,
          corroboration: corroborationScore
        }
      };
    } catch (error) {
      logger.error('Error calculating incident risk:', error);
      throw error;
    }
  }

  // Calculate confidence score based on reporter trust and evidence
  calculateConfidenceScore(incident) {
    const reporterTrust = incident.reporter_trust || 50;
    const hasEvidence = incident.evidence_urls && incident.evidence_urls.length > 0;
    const descriptionLength = incident.description ? incident.description.length : 0;

    let score = reporterTrust * 0.6; // 60% weight on reporter trust

    // Evidence bonus
    if (hasEvidence) {
      score += 20;
    }

    // Description quality
    if (descriptionLength > 50) {
      score += 10;
    } else if (descriptionLength > 20) {
      score += 5;
    }

    return Math.min(100, score);
  }

  // Calculate severity score
  calculateSeverityScore(incident) {
    const severityMap = {
      low: 20,
      medium: 50,
      high: 75,
      critical: 100
    };

    return severityMap[incident.severity] || 50;
  }

  // Calculate temporal score (recency)
  calculateTemporalScore(incident) {
    const hoursSinceIncident = (Date.now() - new Date(incident.incident_time || incident.created_at)) / (1000 * 60 * 60);

    if (hoursSinceIncident < 1) return 100;
    if (hoursSinceIncident < 6) return 80;
    if (hoursSinceIncident < 24) return 60;
    if (hoursSinceIncident < 72) return 40;
    if (hoursSinceIncident < 168) return 20;
    return 10;
  }

  // Calculate spatial score based on nearby incidents
  async calculateSpatialScore(incident) {
    try {
      const query = `
        SELECT COUNT(*) as nearby_count,
          AVG(confidence_score) as avg_nearby_confidence
        FROM incidents
        WHERE 
          ST_Distance(
            location,
            ST_SetSRID(ST_MakePoint($2, $1), 4326)
          ) < 500  -- Within 500 meters
          AND id != $3
          AND status = 'approved'
          AND created_at >= NOW() - INTERVAL '7 days'
      `;
      const result = await pool.query(query, [
        incident.latitude || 0,
        incident.longitude || 0,
        incident.id
      ]);

      const row = result.rows[0];
      const nearbyCount = parseInt(row.nearby_count || 0);
      const avgNearbyConfidence = parseFloat(row.avg_nearby_confidence) || 50;

      // More nearby incidents = higher spatial risk
      let score = 30; // Base score
      score += Math.min(40, nearbyCount * 10); // Up to 40 points for nearby incidents
      score += (avgNearbyConfidence - 50) * 0.3; // Adjust based on nearby confidence

      return Math.min(100, Math.max(0, score));
    } catch (error) {
      logger.error('Error calculating spatial score:', error);
      return 50; // Default to medium
    }
  }

  // Calculate corroboration score
  calculateCorroborationScore(incident) {
    const corroborationCount = incident.corroboration_count || 0;
    const corroborations = incident.corroborations || [];

    // Each corroboration adds confidence
    let score = 30; // Base score for uncorroborated
    score += Math.min(50, corroborationCount * 15); // Up to 50 points for corroborations

    // Check if corroborators have high trust (would need additional query)
    // For MVP, we'll use simple count

    return Math.min(100, score);
  }

  // Calculate area risk score for a location
  async calculateAreaRisk(lat, lng, radiusKm = 1, timeWindowHours = 24) {
    try {
      const query = `
        SELECT 
          COUNT(*) as incident_count,
          AVG(confidence_score) as avg_confidence,
          MAX(severity) as max_severity,
          array_agg(DISTINCT incident_type) as incident_types,
          COUNT(DISTINCT user_id) as unique_reporters
        FROM incidents
        WHERE 
          ST_DWithin(
            location,
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            $3
          )
          AND status = 'approved'
          AND created_at >= NOW() - INTERVAL '${timeWindowHours} hours'
      `;
      const result = await pool.query(query, [lat, lng, radiusKm * 1000]);
      const row = result.rows[0];

      const incidentCount = parseInt(row.incident_count || 0);
      const avgConfidence = parseFloat(row.avg_confidence) || 50;
      const maxSeverity = row.max_severity || 'medium';
      const uniqueReporters = parseInt(row.unique_reporters || 0);

      // Calculate components
      const densityScore = Math.min(100, incidentCount * 10);
      const confidenceScore = avgConfidence;
      const severityScore = this.calculateSeverityScore({ severity: maxSeverity });
      const diversityScore = Math.min(100, (row.incident_types || []).length * 15);
      const reporterDiversityScore = Math.min(100, uniqueReporters * 10);

      // Weighted average
      const riskScore = (
        densityScore * 0.35 +
        confidenceScore * 0.25 +
        severityScore * 0.25 +
        diversityScore * 0.10 +
        reporterDiversityScore * 0.05
      );

      return {
        location: { lat, lng },
        radius_km: radiusKm,
        time_window_hours: timeWindowHours,
        overall_risk_score: Math.min(100, riskScore),
        risk_level: this.getRiskLevel(riskScore),
        incident_count: incidentCount,
        components: {
          density: densityScore,
          confidence: confidenceScore,
          severity: severityScore,
          diversity: diversityScore,
          reporter_diversity: reporterDiversityScore
        },
        incident_types: row.incident_types || [],
        unique_reporters: uniqueReporters
      };
    } catch (error) {
      logger.error('Error calculating area risk:', error);
      throw error;
    }
  }

  // Calculate dynamic risk score (time-adjusted)
  async calculateDynamicRisk(lat, lng, radiusKm = 1) {
    try {
      const currentHour = new Date().getHours();
      const dayOfWeek = new Date().getDay();

      // Get base risk
      const baseRisk = await this.calculateAreaRisk(lat, lng, radiusKm, 24);

      // Time-based multipliers
      let timeMultiplier = 1.0;

      // Night hours (18:00-06:00)
      if (currentHour >= 18 || currentHour < 6) {
        timeMultiplier = 1.5;
      }
      // Peak hours (07:00-09:00, 17:00-19:00)
      else if ((currentHour >= 7 && currentHour < 9) || (currentHour >= 17 && currentHour < 19)) {
        timeMultiplier = 1.2;
      }

      // Weekend adjustment
      if (dayOfWeek === 0 || dayOfWeek === 6) {
        timeMultiplier *= 1.1;
      }

      // Get historical pattern for this time
      const historicalRisk = await this.getHistoricalTimeRisk(lat, lng, currentHour, dayOfWeek, radiusKm);

      // Combine base risk with time multiplier and historical pattern
      const dynamicRisk = baseRisk.overall_risk_score * timeMultiplier;
      const historicalAdjustment = (historicalRisk - 50) * 0.3; // Slight adjustment based on history

      const finalRisk = Math.min(100, Math.max(0, dynamicRisk + historicalAdjustment));

      return {
        ...baseRisk,
        dynamic_risk_score: finalRisk,
        dynamic_risk_level: this.getRiskLevel(finalRisk),
        time_multiplier: timeMultiplier,
        current_hour: currentHour,
        day_of_week: dayOfWeek,
        historical_risk: historicalRisk
      };
    } catch (error) {
      logger.error('Error calculating dynamic risk:', error);
      throw error;
    }
  }

  // Get historical risk for specific time
  async getHistoricalTimeRisk(lat, lng, hour, dayOfWeek, radiusKm = 1) {
    try {
      const query = `
        SELECT AVG(confidence_score) as avg_confidence,
          COUNT(*) as incident_count
        FROM incidents
        WHERE 
          ST_DWithin(
            location,
            ST_SetSRID(ST_MakePoint($2, $1), 4326),
            $3
          )
          AND status = 'approved'
          AND EXTRACT(HOUR FROM incident_time) = $4
          AND EXTRACT(DOW FROM incident_time) = $5
          AND created_at >= NOW() - INTERVAL '90 days'
      `;
      const result = await pool.query(query, [lat, lng, radiusKm * 1000, hour, dayOfWeek]);
      const row = result.rows[0];

      if (row.incident_count === 0) {
        return 50; // Neutral if no historical data
      }

      const historicalRisk = 50 + (row.avg_confidence - 50) * 0.5;
      return Math.min(100, Math.max(0, historicalRisk));
    } catch (error) {
      logger.error('Error getting historical time risk:', error);
      return 50;
    }
  }

  // Get risk level from score
  getRiskLevel(score) {
    if (score < 20) return 'low';
    if (score < 40) return 'moderate';
    if (score < 60) return 'medium';
    if (score < 80) return 'high';
    return 'critical';
  }

  // Batch calculate risk for multiple incidents
  async batchCalculateRisk(incidentIds) {
    try {
      const riskScores = await Promise.all(
        incidentIds.map(id => this.calculateIncidentRisk(id))
      );

      return riskScores;
    } catch (error) {
      logger.error('Error batch calculating risk:', error);
      throw error;
    }
  }
}

module.exports = new RiskScoringService();
