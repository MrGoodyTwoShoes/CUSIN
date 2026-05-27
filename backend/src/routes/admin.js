const express = require('express');
const router = express.Router();
const { authenticateToken, requireAdmin } = require('../middleware/auth');
const moderationService = require('../services/moderationService');

// Get moderation queue
router.get('/moderation/queue', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { limit, priority } = req.query;
    const queue = await moderationService.getQueue(limit, priority);
    res.json({
      success: true,
      data: { queue },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve moderation queue',
      },
    });
  }
});

// Approve incident
router.put('/moderation/queue/:id/approve', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const result = await moderationService.approveIncident(id, req.user.id, notes);
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to approve incident',
      },
    });
  }
});

// Reject incident
router.put('/moderation/queue/:id/reject', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const result = await moderationService.rejectIncident(id, req.user.id, notes);
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to reject incident',
      },
    });
  }
});

module.exports = router;
