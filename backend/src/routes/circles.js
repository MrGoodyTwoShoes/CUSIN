const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { circleQueryRateLimit, generalRateLimit } = require('../middleware/rateLimit');
const circleService = require('../services/circleService');
const logger = require('../config/logger');

// Create circle
router.post('/', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const circle = await circleService.createCircle(req.user.id, req.body);
    res.status(201).json({
      success: true,
      data: { circle },
    });
  } catch (error) {
    logger.error('Error creating circle:', error);
    if (error.message === 'Circle creation rate limit exceeded') {
      return res.status(429).json({
        success: false,
        error: {
          code: 'RATE_LIMIT_EXCEEDED',
          message: 'Circle creation rate limit exceeded (max 3 per day)',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to create circle',
      },
    });
  }
});

// Get circles
router.get('/', authenticateToken, generalRateLimit, circleQueryRateLimit, async (req, res) => {
  try {
    const circles = await circleService.getCircles(req.user.id, req.query);
    res.json({
      success: true,
      data: { circles },
    });
  } catch (error) {
    logger.error('Error getting circles:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve circles',
      },
    });
  }
});

// Get circle by ID
router.get('/:id', authenticateToken, generalRateLimit, circleQueryRateLimit, async (req, res) => {
  try {
    const circle = await circleService.getCircleById(req.params.id, req.user.id);
    if (!circle) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'Circle not found',
        },
      });
    }
    res.json({
      success: true,
      data: { circle },
    });
  } catch (error) {
    logger.error('Error getting circle:', error);
    if (error.message === 'Access denied to private circle') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCESS_DENIED',
          message: 'Access denied to private circle',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve circle',
      },
    });
  }
});

// Add member to circle
router.post('/:id/members', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { user_id, role } = req.body;
    await circleService.addMember(req.params.id, user_id, role);
    res.json({
      success: true,
      data: { message: 'Member added successfully' },
    });
  } catch (error) {
    logger.error('Error adding member:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to add member',
      },
    });
  }
});

// Remove member from circle
router.delete('/:id/members/:userId', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    await circleService.removeMember(req.params.id, req.params.userId);
    res.json({
      success: true,
      data: { message: 'Member removed successfully' },
    });
  } catch (error) {
    logger.error('Error removing member:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to remove member',
      },
    });
  }
});

// Get circle members (privacy-hardened - only returns count)
router.get('/:id/members', authenticateToken, generalRateLimit, circleQueryRateLimit, async (req, res) => {
  try {
    const members = await circleService.getMembers(req.params.id, req.user.id);
    res.json({
      success: true,
      data: { members },
    });
  } catch (error) {
    logger.error('Error getting members:', error);
    if (error.message === 'Access denied') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCESS_DENIED',
          message: 'Access denied to circle members',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve members',
      },
    });
  }
});

// Get full member list (admin only) - NEW
router.get('/:id/members/list', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const members = await circleService.getMemberListForAdmin(req.params.id, req.user.id);
    res.json({
      success: true,
      data: { members },
    });
  } catch (error) {
    logger.error('Error getting member list:', error);
    if (error.message === 'Access denied - admin only') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCESS_DENIED',
          message: 'Admin access required',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve member list',
      },
    });
  }
});

// Update member role
router.put('/:id/members/:userId/role', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { role } = req.body;
    await circleService.updateMemberRole(req.params.id, req.params.userId, role);
    res.json({
      success: true,
      data: { message: 'Member role updated successfully' },
    });
  } catch (error) {
    logger.error('Error updating member role:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to update member role',
      },
    });
  }
});

// Get circle incidents
router.get('/:id/incidents', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const { limit } = req.query;
    const incidents = await circleService.getCircleIncidents(req.params.id, req.user.id, limit);
    res.json({
      success: true,
      data: { incidents },
    });
  } catch (error) {
    logger.error('Error getting circle incidents:', error);
    if (error.message === 'Access denied') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCESS_DENIED',
          message: 'Access denied',
        },
      });
    }
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve circle incidents',
      },
    });
  }
});

// Get user's circles
router.get('/my-circles', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const circles = await circleService.getUserCircles(req.user.id);
    res.json({
      success: true,
      data: { circles },
    });
  } catch (error) {
    logger.error('Error getting user circles:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve user circles',
      },
    });
  }
});

module.exports = router;
