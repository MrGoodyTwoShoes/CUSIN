const pool = require('../config/database');
const geoService = require('../services/geoService');
const trustService = require('../services/trustService');
const moderationService = require('../services/moderationService');
const piiDetector = require('../utils/piiDetector');
const logger = require('../config/logger');

class IncidentController {
  async createIncident(req, res) {
    try {
      const { incident_type, description, latitude, longitude, severity } = req.body;
      const userId = req.user.id;

      // Validate location
      if (!geoService.isWithinKenya(latitude, longitude)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_LOCATION',
            message: 'Location must be within Kenya',
          },
        });
      }

      // Check content safety (PII, doxxing, harassment)
      const safetyCheck = piiDetector.checkContentSafety(description || '');
      
      if (safetyCheck.riskLevel === 'high') {
        logger.warn('High-risk content blocked', { userId, risk: safetyCheck });
        return res.status(400).json({
          success: false,
          error: {
            code: 'CONTENT_VIOLATION',
            message: 'Content violates safety policies and cannot be published',
          },
        });
      }

      // Sanitize content if medium risk
      let sanitizedDescription = description;
      if (safetyCheck.riskLevel === 'medium') {
        sanitizedDescription = piiDetector.sanitizeContent(description);
        logger.info('Content sanitized', { userId, originalRisk: safetyCheck.riskLevel });
      }

      // Fuzz location for privacy (enhanced to 200-300m)
      const fuzzed = geoService.fuzzLocation(latitude, longitude);
      const h3Cell = geoService.latLngToCell(fuzzed.latitude, fuzzed.longitude);

      // Fuzz timestamp for temporal privacy
      const fuzzedTime = geoService.fuzzTimestamp(new Date());

      // Calculate initial confidence score
      const userTrust = await trustService.getCurrentTrustScore(userId);
      const confidenceScore = Math.min(100, userTrust * 0.5 + 50);

      const query = `
        INSERT INTO incidents (
          user_id, incident_type, description, location, h3_cell, 
          fuzzed_location, severity, confidence_score, status, incident_time
        ) VALUES ($1, $2, $3, ST_SetSRID(ST_MakePoint($4, $5), 4326), $6, 
                  ST_SetSRID(ST_MakePoint($7, $8), 4326), $9, $10, 'pending', $11)
        RETURNING id, incident_type, severity, confidence_score, created_at
      `;

      const result = await pool.query(query, [
        userId,
        incident_type,
        sanitizedDescription,
        longitude,
        latitude,
        h3Cell,
        fuzzed.longitude,
        fuzzed.latitude,
        severity || 'medium',
        confidenceScore,
        fuzzedTime.timestamp,
      ]);

      const incident = result.rows[0];

      // Add to moderation queue
      await moderationService.addToQueue(incident.id);

      // Trigger AI triage
      moderationService.aiTriage(incident.id).catch(err => {
        logger.error('AI triage failed:', err);
      });

      res.status(201).json({
        success: true,
        data: { incident },
      });
    } catch (error) {
      logger.error('Error creating incident:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create incident',
        },
      });
    }
  }

  async getIncidents(req, res) {
    try {
      const { lat, lng, radius = 2, limit = 50 } = req.query;

      if (!lat || !lng) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'MISSING_LOCATION',
            message: 'Latitude and longitude are required',
          },
        });
      }

      const incidents = await geoService.getNearbyIncidents(
        parseFloat(lat),
        parseFloat(lng),
        parseFloat(radius),
        parseInt(limit)
      );

      res.json({
        success: true,
        data: { incidents },
      });
    } catch (error) {
      logger.error('Error getting incidents:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to retrieve incidents',
        },
      });
    }
  }

  async getHeatmap(req, res) {
    try {
      const { layer = 'recent' } = req.query;
      const heatmap = await geoService.generateHeatmap(layer);

      res.json({
        success: true,
        data: { heatmap },
      });
    } catch (error) {
      logger.error('Error generating heatmap:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to generate heatmap',
        },
      });
    }
  }

  async getIncidentById(req, res) {
    try {
      const { id } = req.params;

      const query = `
        SELECT 
          id, incident_type, description, severity, confidence_score,
          ST_X(fuzzed_location) as longitude, ST_Y(fuzzed_location) as latitude,
          h3_cell, status, incident_time, created_at
        FROM incidents
        WHERE id = $1
      `;

      const result = await pool.query(query, [id]);

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: 'Incident not found',
          },
        });
      }

      res.json({
        success: true,
        data: { incident: result.rows[0] },
      });
    } catch (error) {
      logger.error('Error getting incident:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to retrieve incident',
        },
      });
    }
  }

  async corroborateIncident(req, res) {
    try {
      const { id } = req.params;
      const userId = req.user.id;

      // Check if incident exists and is approved
      const incidentResult = await pool.query(
        'SELECT id, status, corroborations FROM incidents WHERE id = $1',
        [id]
      );

      if (incidentResult.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: 'Incident not found',
          },
        });
      }

      const incident = incidentResult.rows[0];
      const corroborations = incident.corroborations || [];

      // Check if user already corroborated
      if (corroborations.some(c => c.user_id === userId)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'ALREADY_CORROBORATED',
            message: 'You have already corroborated this incident',
          },
        });
      }

      // Add corroboration
      const newCorroboration = {
        user_id: userId,
        timestamp: new Date().toISOString(),
      };

      const updatedCorroborations = [...corroborations, newCorroboration];

      await pool.query(
        'UPDATE incidents SET corroborations = $1 WHERE id = $2',
        [JSON.stringify(updatedCorroborations), id]
      );

      // Update confidence score
      const newConfidence = Math.min(100, incident.confidence_score + 5);
      await pool.query(
        'UPDATE incidents SET confidence_score = $1 WHERE id = $2',
        [newConfidence, id]
      );

      res.json({
        success: true,
        data: {
          message: 'Incident corroborated successfully',
          new_confidence: newConfidence,
        },
      });
    } catch (error) {
      logger.error('Error corroborating incident:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to corroborate incident',
        },
      });
    }
  }
}

module.exports = new IncidentController();
