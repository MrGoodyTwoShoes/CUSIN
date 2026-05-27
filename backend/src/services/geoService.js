const h3 = require('h3-js');
const pool = require('../config/database');
const logger = require('../config/logger');

class GeoService {
  constructor() {
    this.resolution = parseInt(process.env.H3_RESOLUTION) || 9;
    // Increased fuzzing radius to 200-300m for urban areas (was 75m)
    this.fuzzRadius = parseInt(process.env.LOCATION_FUZZ_RADIUS) || 250;
    this.fuzzRadiusMin = parseInt(process.env.LOCATION_FUZZ_RADIUS_MIN) || 200;
    this.fuzzRadiusMax = parseInt(process.env.LOCATION_FUZZ_RADIUS_MAX) || 300;
    // Temporal fuzzing bins (5-15 minutes)
    this.temporalFuzzMin = parseInt(process.env.TEMPORAL_FUZZ_MIN) || 5;
    this.temporalFuzzMax = parseInt(process.env.TEMPORAL_FUZZ_MAX) || 15;
  }

  // Fuzz location for privacy (enhanced to 200-300m)
  fuzzLocation(lat, lng) {
    // Random radius between min and max for unpredictability
    const radiusInMeters = this.fuzzRadiusMin + Math.random() * (this.fuzzRadiusMax - this.fuzzRadiusMin);
    const randomAngle = Math.random() * 2 * Math.PI;
    const randomDistance = Math.random() * radiusInMeters;
    
    // Convert meters to degrees (approximate)
    const latOffset = (randomDistance * Math.cos(randomAngle)) / 111320;
    const lngOffset = (randomDistance * Math.sin(randomAngle)) / (111320 * Math.cos(lat * Math.PI / 180));
    
    return {
      latitude: lat + latOffset,
      longitude: lng + lngOffset,
      fuzzRadius: radiusInMeters,
    };
  }

  // Fuzz timestamp for temporal privacy (5-15 minute bins)
  fuzzTimestamp(timestamp) {
    const date = new Date(timestamp);
    const fuzzMinutes = this.temporalFuzzMin + Math.random() * (this.temporalFuzzMax - this.temporalFuzzMin);
    
    // Random offset within fuzz range
    const offsetMinutes = (Math.random() - 0.5) * 2 * fuzzMinutes;
    
    const fuzzedDate = new Date(date.getTime() + offsetMinutes * 60 * 1000);
    
    return {
      timestamp: fuzzedDate.toISOString(),
      originalTimestamp: date.toISOString(),
      fuzzMinutes: Math.round(fuzzMinutes),
    };
  }

  // Fuzz timestamp to bin (round to nearest X minutes)
  fuzzTimestampToBin(timestamp, binMinutes = 10) {
    const date = new Date(timestamp);
    const minutes = date.getMinutes();
    const binnedMinutes = Math.floor(minutes / binMinutes) * binMinutes;
    
    date.setMinutes(binnedMinutes);
    date.setSeconds(0);
    date.setMilliseconds(0);
    
    return date.toISOString();
  }

  // Convert lat/lng to H3 cell
  latLngToCell(lat, lng) {
    return h3.latLngToCell(lat, lng, this.resolution);
  }

  // Get H3 cell center
  cellToLatLng(cell) {
    return h3.cellToLatLng(cell);
  }

  // Get nearby cells within radius
  getNearbyCells(lat, lng, radiusKm = 1) {
    const originCell = this.latLngToCell(lat, lng);
    const kRing = h3.kRing(originCell, 2); // 2 rings = approximately 1-2km
    return kRing;
  }

  // Cluster incidents by H3 cell
  async clusterIncidents(timeWindowHours = 24) {
    try {
      const query = `
        SELECT 
          h3_cell,
          COUNT(*) as incident_count,
          AVG(confidence_score) as avg_confidence,
          MAX(severity) as max_severity,
          array_agg(DISTINCT incident_type) as incident_types
        FROM incidents
        WHERE 
          status = 'approved'
          AND incident_time >= NOW() - INTERVAL '${timeWindowHours} hours'
        GROUP BY h3_cell
        HAVING COUNT(*) >= 1
      `;
      const result = await pool.query(query);
      return result.rows;
    } catch (error) {
      logger.error('Error clustering incidents:', error);
      throw error;
    }
  }

  // Generate heatmap data
  async generateHeatmap(layer = 'recent') {
    try {
      let timeWindow = '7 days';
      if (layer === 'live') timeWindow = '2 hours';
      if (layer === 'base') timeWindow = '30 days';

      const query = `
        SELECT 
          h3_cell,
          COUNT(*) as incident_count,
          AVG(confidence_score) as avg_confidence,
          MAX(severity) as max_severity,
          EXTRACT(HOUR FROM incident_time) as hour_bucket
        FROM incidents
        WHERE 
          status = 'approved'
          AND incident_time >= NOW() - INTERVAL '${timeWindow}'
        GROUP BY h3_cell, EXTRACT(HOUR FROM incident_time)
      `;
      const result = await pool.query(query);
      
      // Calculate risk scores
      return result.rows.map(row => ({
        ...row,
        risk_score: this.calculateRiskScore(row),
      }));
    } catch (error) {
      logger.error('Error generating heatmap:', error);
      throw error;
    }
  }

  calculateRiskScore(row) {
    const densityWeight = 0.40;
    const confidenceWeight = 0.30;
    const severityWeight = 0.30;

    const severityMap = { low: 25, medium: 50, high: 75, critical: 100 };
    const severityScore = severityMap[row.max_severity] || 50;

    const riskScore = (
      (Math.min(row.incident_count, 10) / 10) * 100 * densityWeight +
      row.avg_confidence * confidenceWeight +
      severityScore * severityWeight
    );

    return Math.min(100, Math.max(0, riskScore));
  }

  // Get incidents near a location
  async getNearbyIncidents(lat, lng, radiusKm = 2, limit = 50) {
    try {
      const nearbyCells = this.getNearbyCells(lat, lng, radiusKm);
      
      const query = `
        SELECT 
          id,
          incident_type,
          description,
          fuzzed_location,
          severity,
          confidence_score,
          incident_time,
          h3_cell
        FROM incidents
        WHERE 
          status = 'approved'
          AND h3_cell = ANY($1)
        ORDER BY incident_time DESC
        LIMIT $2
      `;
      const result = await pool.query(query, [nearbyCells, limit]);
      return result.rows;
    } catch (error) {
      logger.error('Error getting nearby incidents:', error);
      throw error;
    }
  }

  // Validate location is within Kenya (approximate bounds)
  isWithinKenya(lat, lng) {
    const kenyaBounds = {
      minLat: -4.68,
      maxLat: 5.05,
      minLng: 33.91,
      maxLng: 41.91,
    };
    return (
      lat >= kenyaBounds.minLat &&
      lat <= kenyaBounds.maxLat &&
      lng >= kenyaBounds.minLng &&
      lng <= kenyaBounds.maxLng
    );
  }
}

module.exports = new GeoService();
