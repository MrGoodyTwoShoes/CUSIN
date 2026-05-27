const express = require('express');
const router = express.Router();
const incidentController = require('../controllers/incidentController');
const { authenticateToken } = require('../middleware/auth');
const { validateIncidentCreation, validateIncidentUpdate } = require('../middleware/validation');
const { incidentRateLimit, heatmapRateLimit, locationQueryRateLimit, generalRateLimit } = require('../middleware/rateLimit');

// Create incident
router.post('/', authenticateToken, generalRateLimit, incidentRateLimit, validateIncidentCreation, incidentController.createIncident);

// Get nearby incidents (location query rate limiting)
router.get('/', authenticateToken, generalRateLimit, locationQueryRateLimit, incidentController.getIncidents);

// Get heatmap
router.get('/heatmap', authenticateToken, generalRateLimit, heatmapRateLimit, incidentController.getHeatmap);

// Get incident by ID
router.get('/:id', authenticateToken, generalRateLimit, incidentController.getIncidentById);

// Corroborate incident
router.post('/:id/corroborate', authenticateToken, generalRateLimit, incidentController.corroborateIncident);

module.exports = router;
