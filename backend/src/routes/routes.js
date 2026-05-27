const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const routeService = require('../services/routeService');
const logger = require('../config/logger');

// Calculate safe route
router.post('/safe', authenticateToken, generalRateLimit, routeQueryRateLimit, async (req, res) => {
  try {
    const { origin, destination, options } = req.body;

    if (!origin || !destination || !origin.lat || !origin.lng || !destination.lat || !destination.lng) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'INVALID_COORDINATES',
          message: 'Valid origin and destination coordinates are required',
        },
      });
    }

    const routeResult = await routeService.calculateSafeRoute(origin, destination, options);
    res.json({
      success: true,
      data: routeResult,
    });
  } catch (error) {
    logger.error('Error calculating safe route:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to calculate safe route',
      },
    });
  }
});

// Get area risk summary
router.get('/area-risk', authenticateToken, async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'MISSING_COORDINATES',
          message: 'Latitude and longitude are required',
        },
      });
    }

    const riskSummary = await routeService.getAreaRiskSummary(
      parseFloat(lat),
      parseFloat(lng),
      radius ? parseFloat(radius) : 2
    );

    res.json({
      success: true,
      data: riskSummary,
    });
  } catch (error) {
    logger.error('Error getting area risk summary:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve area risk summary',
      },
    });
  }
});

// Get safe corridors
router.get('/safe-corridors', authenticateToken, generalRateLimit, locationQueryRateLimit, async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'MISSING_COORDINATES',
          message: 'Latitude and longitude are required',
        },
      });
    }

    const safeCorridors = await routeService.getSafeCorridors(
      parseFloat(lat),
      parseFloat(lng),
      radius ? parseFloat(radius) : 5
    );

    res.json({
      success: true,
      data: safeCorridors,
    });
  } catch (error) {
    logger.error('Error getting safe corridors:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve safe corridors',
      },
    });
  }
});

module.exports = router;
