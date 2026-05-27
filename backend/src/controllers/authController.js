const pool = require('../config/database');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const logger = require('../config/logger');

class AuthController {
  async register(req, res) {
    try {
      const { phone } = req.body;

      // Validate phone number
      if (!phone || !/^\+?[1-9]\d{1,14}$/.test(phone)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_PHONE',
            message: 'Valid phone number is required',
          },
        });
      }

      // Hash phone number for privacy
      const phoneHash = crypto
        .createHash('sha256')
        .update(phone)
        .digest('hex');

      // Check if user already exists
      const existingUser = await pool.query(
        'SELECT id FROM users WHERE phone_hash = $1',
        [phoneHash]
      );

      if (existingUser.rows.length > 0) {
        // User exists, generate token
        const userId = existingUser.rows[0].id;
        const token = this.generateToken(userId);

        return res.json({
          success: true,
          data: {
            token,
            user_id: userId,
            existing_user: true,
          },
        });
      }

      // Create new user
      const result = await pool.query(
        'INSERT INTO users (phone_hash, trust_score, account_status) VALUES ($1, 50.00, $2) RETURNING id',
        [phoneHash, 'active']
      );

      const userId = result.rows[0].id;
      const token = this.generateToken(userId);

      res.status(201).json({
        success: true,
        data: {
          token,
          user_id: userId,
          existing_user: false,
        },
      });
    } catch (error) {
      logger.error('Error registering user:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to register user',
        },
      });
    }
  }

  async verifyPhone(req, res) {
    try {
      const { phone, code } = req.body;

      // In production, integrate with Twilio or similar SMS service
      // For MVP, we'll accept any 6-digit code for testing
      if (!code || code.length !== 6 || !/^\d{6}$/.test(code)) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_CODE',
            message: 'Invalid verification code',
          },
        });
      }

      // For MVP: accept code "123456" for testing
      if (code !== '123456') {
        return res.status(400).json({
          success: false,
          error: {
            code: 'INVALID_CODE',
            message: 'Invalid verification code',
          },
        });
      }

      res.json({
        success: true,
        data: { message: 'Phone verified successfully' },
      });
    } catch (error) {
      logger.error('Error verifying phone:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to verify phone',
        },
      });
    }
  }

  async login(req, res) {
    try {
      const { phone } = req.body;

      if (!phone) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'MISSING_PHONE',
            message: 'Phone number is required',
          },
        });
      }

      // Hash phone number
      const phoneHash = crypto
        .createHash('sha256')
        .update(phone)
        .digest('hex');

      // Find user
      const result = await pool.query(
        'SELECT id, account_status FROM users WHERE phone_hash = $1',
        [phoneHash]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({
          success: false,
          error: {
            code: 'USER_NOT_FOUND',
            message: 'User not found',
          },
        });
      }

      const user = result.rows[0];

      if (user.account_status !== 'active') {
        return res.status(403).json({
          success: false,
          error: {
            code: 'ACCOUNT_SUSPENDED',
            message: 'Account is suspended or banned',
          },
        });
      }

      const token = this.generateToken(user.id);

      res.json({
        success: true,
        data: { token, user_id: user.id },
      });
    } catch (error) {
      logger.error('Error logging in:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to login',
        },
      });
    }
  }

  generateToken(userId) {
    return jwt.sign(
      { id: userId, role: 'user' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );
  }

  async getMe(req, res) {
    try {
      const userId = req.user.id;

      const result = await pool.query(
        'SELECT id, display_name, trust_score, account_status, created_at FROM users WHERE id = $1',
        [userId]
      );

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
  }
}

module.exports = new AuthController();
