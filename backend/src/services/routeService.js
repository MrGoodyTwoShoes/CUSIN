const pool = require('../config/database');
const geoService = require('./geoService');
const logger = require('../config/logger');

class RouteService {
  constructor() {
    // Risk multipliers based on time of day
    this.timeRiskMultipliers = {
      night: { start: 18, end: 6, multiplier: 1.5 },
      peak: { start: 7, end: 9, multiplier: 1.2 },
      evening_peak: { start: 17, end: 19, multiplier: 1.3 },
    };
  }

  // Calculate risk score for a route segment
  calculateSegmentRisk(incidents, segmentLength) {
    if (!incidents || incidents.length === 0) {
      return 0;
    }

    const severityWeights = {
      low: 10,
      medium: 30,
      high: 60,
      critical: 100,
    };

    let totalRisk = 0;
    incidents.forEach(incident => {
      const severityWeight = severityWeights[incident.severity] || 30;
      const confidenceFactor = incident.confidence_score / 100;
      totalRisk += severityWeight * confidenceFactor;
    });

    // Normalize by segment length (risk per km)
    const riskPerKm = totalRisk / (segmentLength || 1);
    return Math.min(100, riskPerKm);
  }

  // Get time-based risk multiplier
  getTimeRiskMultiplier(hour) {
    for (const [type, config] of Object.entries(this.timeRiskMultipliers)) {
      if (config.start <= 24 && config.end >= 0) {
        // Night time (crosses midnight)
        if (hour >= config.start || hour < config.end) {
          return config.multiplier;
        }
      } else {
        // Normal time range
        if (hour >= config.start && hour < config.end) {
          return config.multiplier;
        }
      }
    }
    return 1.0;
  }

  // Get incidents along a route (simplified - in production would use routing engine)
  async getIncidentsAlongRoute(waypoints, timeWindow = '7 days') {
    try {
      // Get H3 cells for each waypoint
      const cells = waypoints.map(wp => 
        geoService.latLngToCell(wp.lat, wp.lng)
      );

      // Get nearby cells (k-ring of 2 for ~1-2km coverage)
      const nearbyCells = new Set();
      cells.forEach(cell => {
        const kRing = geoService.getNearbyCells(
          geoService.cellToLatLng(cell).lat,
          geoService.cellToLatLng(cell).lng,
          2
        );
        kRing.forEach(c => nearbyCells.add(c));
      });

      const query = `
        SELECT 
          id, incident_type, severity, confidence_score,
          ST_X(fuzzed_location) as longitude, ST_Y(fuzzed_location) as latitude,
          h3_cell, incident_time
        FROM incidents
        WHERE 
          h3_cell = ANY($1)
          AND status = 'approved'
          AND incident_time >= NOW() - INTERVAL '${timeWindow}'
        ORDER BY incident_time DESC
      `;

      const result = await pool.query(query, [Array.from(nearbyCells)]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting incidents along route:', error);
      throw error;
    }
  }

  // Calculate safe route (simplified - in production would use OSRM/GraphHopper)
  async calculateSafeRoute(origin, destination, options = {}) {
    try {
      const { 
        avoid_high_risk = true, 
        max_detour_percent = 30,
        time_preference = 'now'
      } = options;

      // Get current hour for time-based risk
      const currentHour = new Date().getHours();
      const timeMultiplier = this.getTimeRiskMultiplier(currentHour);

      // Get waypoints (simplified straight line with intermediate points)
      const waypoints = this.generateWaypoints(origin, destination, 5);
      
      // Get incidents along route
      const incidents = await this.getIncidentsAlongRoute(waypoints);
      
      // Calculate base route risk
      const baseRisk = this.calculateSegmentRisk(incidents, this.calculateDistance(origin, destination));
      const adjustedRisk = baseRisk * timeMultiplier;

      // Generate alternative routes (simplified - would use routing engine)
      const alternatives = this.generateAlternativeRoutes(origin, destination, 2);
      
      // Calculate risk for each alternative
      const scoredRoutes = await Promise.all(
        alternatives.map(async (altRoute) => {
          const altWaypoints = this.generateWaypoints(altRoute.origin, altRoute.destination, 5);
          const altIncidents = await this.getIncidentsAlongRoute(altWaypoints);
          const altRisk = this.calculateSegmentRisk(altIncidents, altRoute.distance);
          const altAdjustedRisk = altRisk * timeMultiplier;

          return {
            ...altRoute,
            risk_score: altAdjustedRisk,
            incident_count: altIncidents.length,
            risk_level: this.getRiskLevel(altAdjustedRisk),
          };
        })
      );

      // Sort by risk score
      scoredRoutes.sort((a, b) => a.risk_score - b.risk_score);

      return {
        recommended_route: scoredRoutes[0] || null,
        alternatives: scoredRoutes.slice(1),
        base_route: {
          origin,
          destination,
          distance: this.calculateDistance(origin, destination),
          risk_score: adjustedRisk,
          incident_count: incidents.length,
          risk_level: this.getRiskLevel(adjustedRisk),
        },
        time_multiplier: timeMultiplier,
        current_hour: currentHour,
      };
    } catch (error) {
      logger.error('Error calculating safe route:', error);
      throw error;
    }
  }

  // Generate waypoints between origin and destination (simplified)
  generateWaypoints(origin, destination, count) {
    const waypoints = [origin];
    for (let i = 1; i < count; i++) {
      const ratio = i / count;
      waypoints.push({
        lat: origin.lat + (destination.lat - origin.lat) * ratio,
        lng: origin.lng + (destination.lng - origin.lng) * ratio,
      });
    }
    waypoints.push(destination);
    return waypoints;
  }

  // Generate alternative routes (simplified - would use routing engine)
  generateAlternativeRoutes(origin, destination, count) {
    const alternatives = [];
    const baseDistance = this.calculateDistance(origin, destination);

    for (let i = 1; i <= count; i++) {
      // Add offset to create alternative paths
      const offset = i * 0.01; // ~1km offset
      alternatives.push({
        origin: { lat: origin.lat + offset, lng: origin.lng },
        destination: { lat: destination.lat + offset, lng: destination.lng },
        distance: baseDistance * (1 + i * 0.1), // 10% longer per alternative
        detour_percent: i * 10,
      });
    }

    return alternatives;
  }

  // Calculate distance between two points (Haversine formula)
  calculateDistance(point1, point2) {
    const R = 6371; // Earth's radius in km
    const dLat = this.toRad(point2.lat - point1.lat);
    const dLon = this.toRad(point2.lng - point1.lng);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(point1.lat)) *
        Math.cos(this.toRad(point2.lat)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  toRad(degrees) {
    return degrees * (Math.PI / 180);
  }

  // Get risk level from score
  getRiskLevel(score) {
    if (score < 20) return 'low';
    if (score < 40) return 'moderate';
    if (score < 60) return 'medium';
    if (score < 80) return 'high';
    return 'critical';
  }

  // Get area risk summary for a location
  async getAreaRiskSummary(lat, lng, radiusKm = 2) {
    try {
      const nearbyCells = geoService.getNearbyCells(lat, lng, radiusKm);
      const currentHour = new Date().getHours();
      const timeMultiplier = this.getTimeRiskMultiplier(currentHour);

      const query = `
        SELECT 
          incident_type,
          COUNT(*) as count,
          AVG(confidence_score) as avg_confidence,
          MAX(severity) as max_severity
        FROM incidents
        WHERE 
          h3_cell = ANY($1)
          AND status = 'approved'
          AND incident_time >= NOW() - INTERVAL '7 days'
        GROUP BY incident_type
      `;

      const result = await pool.query(query, [nearbyCells]);
      const incidentsByType = result.rows;

      // Calculate overall risk
      let totalRisk = 0;
      incidentsByType.forEach(row => {
        const severityWeights = { low: 10, medium: 30, high: 60, critical: 100 };
        const severityWeight = severityWeights[row.max_severity] || 30;
        totalRisk += (row.count * severityWeight * (row.avg_confidence / 100));
      });

      const adjustedRisk = Math.min(100, totalRisk * timeMultiplier);

      return {
        location: { lat, lng },
        radius_km: radiusKm,
        overall_risk_score: adjustedRisk,
        risk_level: this.getRiskLevel(adjustedRisk),
        incidents_by_type: incidentsByType,
        time_multiplier: timeMultiplier,
        current_hour: currentHour,
      };
    } catch (error) {
      logger.error('Error getting area risk summary:', error);
      throw error;
    }
  }

  // Get safe corridors (low-risk areas)
  async getSafeCorridors(lat, lng, radiusKm = 5) {
    try {
      const nearbyCells = geoService.getNearbyCells(lat, lng, radiusKm);

      const query = `
        SELECT 
          h3_cell,
          COUNT(*) as incident_count,
          AVG(confidence_score) as avg_confidence
        FROM incidents
        WHERE 
          h3_cell = ANY($1)
          AND status = 'approved'
          AND incident_time >= NOW() - INTERVAL '7 days'
        GROUP BY h3_cell
      `;

      const result = await pool.query(query, [nearbyCells]);
      const cellRisks = result.rows;

      // Identify low-risk cells
      const safeCells = cellRisks
        .filter(cell => cell.incident_count === 0 || cell.avg_confidence < 30)
        .map(cell => ({
          h3_cell: cell.h3_cell,
          center: geoService.cellToLatLng(cell.h3_cell),
          risk_score: cell.incident_count === 0 ? 0 : cell.avg_confidence,
        }));

      return {
        location: { lat, lng },
        radius_km: radiusKm,
        safe_cells: safeCells,
        safe_cell_count: safeCells.length,
      };
    } catch (error) {
      logger.error('Error getting safe corridors:', error);
      throw error;
    }
  }
}

module.exports = new RouteService();
