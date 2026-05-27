const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { generalRateLimit } = require('../middleware/rateLimit');
const pool = require('../config/database');
const trustService = require('../services/trustService');
const logger = require('../config/logger');

// Get current user
router.get('/me', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.id;

    const query = `
      SELECT id, display_name, trust_score, account_status, created_at, last_active
      FROM users
      WHERE id = $1
    `;
    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    res.json({
      success: true,
      data: { user: result.rows[0] },
    });
  } catch (error) {
    logger.error('Error getting user:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve user',
      },
    });
  }
});

// Get user trust score
router.get('/me/trust-score', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.id;
    const trustScore = await trustService.getCurrentTrustScore(userId);

    // Get trust history
    const historyQuery = `
      SELECT event_type, score_change, previous_score, new_score, reason, created_at
      FROM trust_events
      WHERE user_id = $1
      ORDER BY created_at DESC
      LIMIT 20
    `;
    const historyResult = await pool.query(historyQuery, [userId]);

    res.json({
      success: true,
      data: {
        trust_score: trustScore,
        history: historyResult.rows,
      },
    });
  } catch (error) {
    logger.error('Error getting trust score:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve trust score',
      },
    });
  }
});

// Get user's incidents
router.get('/me/incidents', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.id;
    const { limit = 20, offset = 0, status } = req.query;

    let query = `
      SELECT 
        id, incident_type, description, severity, confidence_score,
        ST_X(fuzzed_location) as longitude, ST_Y(fuzzed_location) as latitude,
        h3_cell, status, incident_time, created_at
      FROM incidents
      WHERE user_id = $1
    `;
    const params = [userId];
    let paramIndex = 2;

    if (status) {
      query += ` AND status = $${paramIndex++}`;
      params.push(status);
    }

    query += ` ORDER BY created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);

    // Get total count
    const countQuery = `
      SELECT COUNT(*) as total
      FROM incidents
      WHERE user_id = $1
      ${status ? 'AND status = $2' : ''}
    `;
    const countParams = status ? [userId, status] : [userId];
    const countResult = await pool.query(countQuery, countParams);

    res.json({
      success: true,
      data: {
        incidents: result.rows,
        pagination: {
          total: parseInt(countResult.rows[0].total),
          limit: parseInt(limit),
          offset: parseInt(offset),
        },
      },
    });
  } catch (error) {
    logger.error('Error getting user incidents:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to retrieve user incidents',
      },
    });
  }
});

// Update user profile
router.put('/me', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.id;
    const { display_name, privacy_settings } = req.body;

    const updates = [];
    const params = [];
    let paramIndex = 1;

    if (display_name !== undefined) {
      updates.push(`display_name = $${paramIndex++}`);
      params.push(display_name);
    }

    if (privacy_settings !== undefined) {
      updates.push(`privacy_settings = $${paramIndex++}`);
      params.push(JSON.stringify(privacy_settings));
    }

    if (updates.length === 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'NO_UPDATES',
          message: 'No fields to update',
        },
      });
    }

    params.push(userId);

    const query = `
      UPDATE users
      SET ${updates.join(', ')}, last_active = NOW()
      WHERE id = $${paramIndex}
      RETURNING id, display_name, trust_score, account_status
    `;

    const result = await pool.query(query, params);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    res.json({
      success: true,
      data: { user: result.rows[0] },
    });
  } catch (error) {
    logger.error('Error updating user:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to update user',
      },
    });
  }
});

// Delete user account
router.delete('/me', authenticateToken, generalRateLimit, async (req, res) => {
  try {
    const userId = req.user.id;

    // Soft delete - mark account as deleted
    const query = `
      UPDATE users
      SET account_status = 'deleted', display_name = NULL, last_active = NOW()
      WHERE id = $1
      RETURNING id
    `;

    const result = await pool.query(query, [userId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'User not found',
        },
      });
    }

    res.json({
      success: true,
      data: { message: 'Account deleted successfully' },
    });
  } catch (error) {
    logger.error('Error deleting user:', error);
    res.status(500).json({
      success: false,
      error: {
        code: 'INTERNAL_ERROR',
        message: 'Failed to delete account',
      },
    });
  }
});

module.exports = router;
